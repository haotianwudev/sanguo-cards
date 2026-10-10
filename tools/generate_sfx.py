"""Synthesise placeholder sound effects into godot/data/audio/sfx/gen/ (mono 16-bit WAV, 22050 Hz).

    python tools/generate_sfx.py

Only writes into the gen/ folder, so it never overwrites real assets: when a proper sound arrives, put it in
godot/data/audio/sfx/ and point its entry in godot/data/audio.json at it. Deterministic (fixed seeds).
"""
import wave
from pathlib import Path

import numpy as np

SR = 22050
OUT = Path(__file__).resolve().parents[1] / "godot/data/audio/sfx/gen"


def t(dur):
    return np.arange(int(SR * dur)) / SR


def env(n, attack=0.004, decay=8.0):
    x = np.arange(n) / SR
    a = np.clip(x / max(attack, 1e-4), 0, 1)
    return a * np.exp(-decay * x)


def lowpass(x, cutoff):
    alpha = 1 - np.exp(-2 * np.pi * cutoff / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc += alpha * (v - acc)
        y[i] = acc
    return y


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def sweep(f0, f1, dur, decay=10.0):
    x = t(dur)
    f = f0 * (f1 / f0) ** (x / dur)
    phase = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(phase) * env(len(x), 0.002, decay)


def noise(dur, rng, decay=20.0, attack=0.001):
    n = int(SR * dur)
    return rng.uniform(-1, 1, n) * env(n, attack, decay)


def ring(freqs, dur, decay=6.0, amps=None):
    x = t(dur)
    amps = amps or [1.0 / (i + 1) for i in range(len(freqs))]
    s = sum(a * np.sin(2 * np.pi * f * x) for f, a in zip(freqs, amps))
    return s * env(len(x), 0.001, decay)


def whoosh(dur, rng, lo=400, hi=3000, rise=0.35):
    n = int(SR * dur)
    w = rng.uniform(-1, 1, n)
    x = np.arange(n) / n
    shape = np.where(x < rise, x / rise, (1 - x) / (1 - rise)) ** 1.5
    band = highpass(lowpass(w, hi), lo)
    return band * shape


def pluck(freq, dur, rng, damp=0.996):
    n = int(SR * dur)
    period = int(SR / freq)
    buf = rng.uniform(-1, 1, period)
    out = np.empty(n)
    for i in range(n):
        out[i] = buf[i % period]
        buf[i % period] = damp * 0.5 * (buf[i % period] + buf[(i + 1) % period])
    return out


def mix(*parts):
    n = max(len(p) for _, p in parts)
    out = np.zeros(n)
    for off, p in parts:
        o = int(off * SR)
        end = min(n, o + len(p))
        if o < n:
            out[o:end] += p[: end - o]
    return out


def save(name, x, peak=0.85):
    x = np.asarray(x, dtype=float)
    fade = min(len(x), int(0.01 * SR))
    x[-fade:] *= np.linspace(1, 0, fade)
    m = np.max(np.abs(x)) or 1.0
    data = (x / m * peak * 32767).astype(np.int16)
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def main():
    rng = np.random.default_rng(7)
    # ---- 出招 (a unit acts): one per troop, plus the once-per-battle 大招
    save("act_cavalry", mix((0, sweep(110, 60, 0.12, 30)), (0.09, sweep(100, 55, 0.12, 30)), (0.05, 0.5 * whoosh(0.3, rng, 300, 2500))))
    save("act_spear", mix((0, 0.9 * whoosh(0.2, rng, 900, 5000, 0.6)), (0.15, 0.3 * ring([2400, 3600], 0.15, 25))))
    save("act_archer", mix((0, 0.35 * lowpass(noise(0.18, rng, 6), 600)), (0.16, pluck(196, 0.35, rng, 0.994)), (0.17, 0.4 * whoosh(0.18, rng, 1500, 6000, 0.2))))
    save("act_infantry", mix((0, 0.7 * whoosh(0.22, rng, 2000, 7000, 0.8)), (0.16, 0.5 * ring([1800, 2750, 4100], 0.4, 7))))
    save("act_lord", mix((0, 0.8 * whoosh(0.26, rng, 1200, 6000, 0.8)), (0.2, 0.6 * ring([1300, 2050, 3300], 0.5, 6)), (0.2, 0.5 * sweep(140, 70, 0.15, 20))))
    save("act_strategist", mix((0, 0.6 * ring([1320, 3640], 0.5, 6)), (0.09, 0.6 * ring([1760, 4850], 0.5, 6)), (0.18, 0.6 * ring([2090, 5760], 0.6, 5))))
    save("act_bandit", mix((0, 0.8 * whoosh(0.16, rng, 500, 2500, 0.5)), (0.12, 0.4 * highpass(noise(0.03, rng, 80), 2000))))
    save("act_logistics", mix((0, sweep(180, 120, 0.18, 18)), (0.12, 0.6 * sweep(220, 150, 0.15, 20))))
    save("act_ultimate", mix((0, 0.7 * whoosh(0.5, rng, 300, 4000, 0.7)), (0.35, ring([110, 164, 262, 392, 523], 1.4, 2.2, [1, 0.8, 0.6, 0.4, 0.3]))))
    # ---- 打击 (our hits on the enemy)
    for i, (f0, crack) in enumerate([(150, 0.6), (130, 0.7), (170, 0.5)]):
        save(f"hit_{i + 1}", mix((0, sweep(f0, 55, 0.16, 18)), (0, crack * highpass(noise(0.06, rng, 45), 1500))))
    save("hit_heavy", mix((0, sweep(120, 38, 0.4, 7)), (0, 0.9 * lowpass(noise(0.35, rng, 9), 2500)), (0, 0.5 * highpass(noise(0.05, rng, 60), 2500))))
    save("hit_magic", mix((0, 0.8 * sweep(1400, 260, 0.25, 9)), (0.02, 0.5 * ring([2600, 3900], 0.35, 9)), (0, 0.3 * highpass(noise(0.08, rng, 30), 3000))))
    save("hit_pierce", mix((0, highpass(noise(0.04, rng, 90), 3000)), (0.005, 0.6 * ring([3200, 4700], 0.25, 14)), (0, 0.6 * sweep(220, 90, 0.1, 30))))
    save("slash", mix((0, whoosh(0.18, rng, 1500, 7000, 0.7)), (0.12, 0.35 * ring([2900, 4300], 0.2, 18))))
    crackle = np.zeros(int(SR * 0.5))
    for _ in range(60):
        p = rng.integers(0, len(crackle) - 400)
        crackle[p:p + 400] += rng.uniform(0.2, 1.0) * highpass(noise(400 / SR, rng, 300), 1200)
    save("burn", mix((0, crackle), (0, 0.5 * lowpass(noise(0.5, rng, 4), 500))))
    # ---- the enemy's side
    for i, f0 in enumerate([95, 80]):
        save(f"enemy_hit_{i + 1}", mix((0, sweep(f0, 32, 0.45, 6)), (0, 0.8 * lowpass(noise(0.3, rng, 10), 1800)), (0.02, 0.4 * highpass(noise(0.08, rng, 40), 1200))))
    save("charge", 0.9 * lowpass(rng.uniform(-1, 1, int(SR * 0.7)) * np.linspace(0.1, 1, int(SR * 0.7)), 300) + 0.4 * np.sin(2 * np.pi * 55 * t(0.7)) * np.linspace(0, 1, int(SR * 0.7)))
    # ---- support and statuses
    save("guard", mix((0, ring([620, 1380, 2210], 0.35, 10)), (0, 0.5 * sweep(200, 120, 0.08, 40))))
    save("heal", mix((0, 0.7 * ring([880, 1760], 0.5, 5)), (0.12, 0.7 * ring([1320, 2640], 0.6, 4))))
    save("buff", mix(*[(0.06 * k, 0.5 * ring([660 * 2 ** (k / 4), 1320 * 2 ** (k / 4)], 0.4, 7)) for k in range(5)]))
    save("stun", mix((0, ring([420, 1130], 0.15, 25)), (0.06, 0.6 * ring([2200, 2600], 0.5, 6))))
    save("break", mix((0, highpass(noise(0.12, rng, 25), 1800)), (0.03, 0.6 * sweep(2400, 600, 0.3, 8)), (0, 0.6 * sweep(150, 60, 0.15, 20))))
    # ---- ends and the map
    save("win", mix((0, sweep(140, 70, 0.2, 14)), (0.18, sweep(140, 70, 0.2, 14)), (0.36, sweep(160, 80, 0.2, 14)), (0.5, ring([131, 196, 262, 392, 523], 1.6, 1.8))))
    save("lose", mix((0, ring([196, 294], 0.6, 3)), (0.4, ring([175, 262], 0.6, 3)), (0.8, ring([131, 196], 1.2, 2))))
    save("step", mix((0, ring([880, 1560], 0.09, 45)), (0, 0.4 * sweep(300, 180, 0.05, 60))), 0.6)
    print("wrote", len(list(OUT.glob("*.wav"))), "files to", OUT)


if __name__ == "__main__":
    main()
