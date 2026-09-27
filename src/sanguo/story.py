"""Branching story: a graph of nodes, each a list of steps. Pure logic — the CLI renders steps and calls advance().

Step kinds:
  {"text": [lines]}                                   show lines ({lord} is replaced)
  {"choose": [{"card", "label", "goto"}, ...]}        pick one: that card joins, story jumps to "goto"
  {"battle": scenario_id}                             must win to continue
  {"give": {"cards": [...]}}                          reward cards
A node ends by jumping to its "next" node; a node with no "next" is the (current) end of the story.
"""
from __future__ import annotations

import json
from dataclasses import dataclass
from importlib import resources

from . import collection as col
from .cards import CardDB


@dataclass(frozen=True)
class Node:
    id: str
    title: str
    steps: tuple[dict, ...]
    next: str | None


@dataclass(frozen=True)
class Story:
    start: str
    nodes: dict[str, Node]


def load_story(db: CardDB, raw: dict | None = None) -> Story:
    if raw is None:
        raw = json.loads(resources.files("sanguo.data").joinpath("story.json").read_text("utf-8"))
    nodes = {nid: Node(nid, n["title"], tuple(n["steps"]), n.get("next")) for nid, n in raw["nodes"].items()}
    story = Story(raw["start"], nodes)
    _validate(db, story)
    return story


def _validate(db: CardDB, story: Story) -> None:
    def need_node(nid: str, where: str) -> None:
        if nid not in story.nodes:
            raise ValueError(f"{where}: unknown story node {nid}")

    need_node(story.start, "start")
    for n in story.nodes.values():
        if n.next:
            need_node(n.next, n.id)
        for i, st in enumerate(n.steps):
            where = f"{n.id}[{i}]"
            (kind,) = st.keys()
            if kind == "choose":
                for opt in st["choose"]:
                    if opt["card"] not in db.cards:
                        raise ValueError(f"{where}: unknown card {opt['card']}")
                    need_node(opt["goto"], where)
            elif kind == "battle":
                if st["battle"] not in db.scenarios:
                    raise ValueError(f"{where}: unknown battle {st['battle']}")
            elif kind == "give":
                bad = [c for c in st["give"].get("cards", []) if c not in db.cards]
                if bad:
                    raise ValueError(f"{where}: unknown cards {bad}")
            elif kind != "text":
                raise ValueError(f"{where}: unknown step kind {kind}")


def current(story: Story, save: col.Save) -> tuple[Node, dict] | None:
    """The node and step the player is on, or None once the story runs out."""
    node = story.nodes[save.story_node or story.start]
    if save.story_step >= len(node.steps):
        return None
    return node, node.steps[save.story_step]


def kind(step: dict) -> str:
    (k,) = step.keys()
    return k


def advance(db: CardDB, story: Story, save: col.Save, choice: int | None = None) -> None:
    """Resolve the current step and move on. Battles are resolved by the caller (only call after a win)."""
    cur = current(story, save)
    if cur is None:
        return
    node, step = cur
    k = kind(step)
    if k == "choose":
        opt = step["choose"][choice]
        col.grant_card(db, save, opt["card"])
        save.story_path.append(opt["goto"])
        _goto(story, save, opt["goto"])
        return
    if k == "give":
        for cid in step["give"].get("cards", []):
            col.grant_card(db, save, cid)
    save.story_step += 1
    if save.story_step >= len(node.steps) and node.next:
        _goto(story, save, node.next)


def _goto(story: Story, save: col.Save, node_id: str) -> None:
    save.story_node = node_id
    save.story_step = 0


def finished(story: Story, save: col.Save) -> bool:
    return current(story, save) is None
