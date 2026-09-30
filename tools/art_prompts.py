"""Write pics/ART-PROMPTS.md: a ready-to-paste image prompt for every piece of art the game still needs.

    python tools/art_prompts.py

Portraits, battle CGs and story CGs each follow one template (composition + style are fixed so the set stays
consistent); only the subject lines differ. Items that already have final art in pics/art.json are skipped.
Add new characters / battles / scenes to the tables below when you add them to the game.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PICS = ROOT / "pics"
NL = "\n"

DONGBAI = ("Dong Bai: an adult woman general with long silver-white hair in a high ponytail, purple fur-trimmed leather armor "
           "and two huge bronze hammers (her delivered portrait and CGs all look like this)")
HERO = "the hero: a young man with short, modern-style black hair (unusual in the Han dynasty), wearing Sun Jian's old silver armor with tiger-engraved shoulder guards over a green tunic, a black cape trimmed with white fur (not a tiger pelt), a tiger-pelt lining showing under the armor skirt, carrying Sun Jian's huge old broad-bladed saber over his shoulder"
STYLE = ("Retro Japanese tactical anime RPG card illustration, Rance X art style inspiration, cel-shaded with crisp clean "
         "ink outlines, rich vibrant colors")
PORTRAIT_COMPOSITION = ("Vertical 3:4 aspect ratio, waist-up portrait, character centered, face positioned neatly in the upper "
                        "third of the canvas, head fully visible with margin at the top.")
# Backgrounds are now atmospheric and character-specific per user directive

# key: (name line, appearance, armor & clothing, weapon / pose)
PORTRAITS = {
    "diaochan": ("Diaochan (貂蝉), the famed beauty and Wang Yun's adoptive daughter — clever, brave, always seeming to flirt — an adult woman",
        "Breathtakingly beautiful adult woman in her early 20s with a teasing, unreadable smile and knowing eyes.",
        "Flowing layered silk dress in moonlit blue and silver with long dancing sleeves, a jade hairpin.",
        "A round silk fan held half open, one long sleeve drifting in the air.",
        "a moonlit garden with a round moon gate and curling incense smoke"),
    "huangzhong": ("Huang Zhong (黄忠), a Nanyang man in his forties and a peerless archer — not yet the old general of legend",
        "Sturdy, weathered man in his early 40s with a square jaw, a short beard and steady eyes.",
        "Rough soldier's clothes with a leather bracer, rope marks still on his wrists.",
        "A heavy longbow drawn to full, an arrow nocked.",
        "a Nanyang army camp gate in summer with a broken 袁 banner pole"),
    "xuhuang": ("Xu Huang (徐晃), a dark-faced Hedong officer under Yang Feng who kneels to the emperor",
        "Dark-skinned, stern man in his 30s with thick brows and an honest, stubborn look.",
        "Plain iron lamellar armor with a dusty brown cloak.",
        "A huge long-handled battle axe resting on his shoulder.",
        "a mountain pass east of Huayin with Yang Feng's banners"),
    "bingzhou": ("a Bingzhou wolf rider (并州狼骑), one of Lü Bu's northern cavalrymen",
        "Fierce, wind-burned northern horseman in his 20s with a wolfish grin.",
        "Fur-trimmed leather and iron armor, a wolf tail hanging from his helmet.",
        "A curved saber raised as he gallops.",
        "the open northern steppe at dusk"),
    "xianzhen": ("a Trap-Breaking Camp soldier (陷阵营), Gao Shun's silent elite infantry",
        "Grim, silent heavy infantryman, his face half hidden by a deep helmet.",
        "Heavy black lamellar armor, plain and unadorned.",
        "A tall rectangular black shield and a long ji.",
        "a shield wall in the dark before dawn"),
    "xurong": ("Xu Rong (徐荣), Dong Zhuo's veteran general who beat Sun Jian at Liangdong",
        "Weathered, calm general in his 40s with a grey-streaked beard and a hard, measuring gaze.",
        "Well-worn Xiliang lamellar armor with a dark red cloak.",
        "A ring-pommel saber at his side, one hand pointing out an ambush.",
        "a valley outside the Dagu pass with hidden troops on the slopes"),
    "zhurong": ("Lady Zhurong (祝融夫人), queen of the Nanzhong tribes who claims descent from the fire god — an adult woman",
        "Proud, sun-bronzed adult woman around 30 with a fierce grin, wild dark hair bound with red cords, gold and bone earrings.",
        "Tribal queen's armor of leather and bronze plates, a leopard pelt over one shoulder, feather ornaments.",
        "A bandolier of throwing knives across her chest, one knife twirling between her fingers.",
        "a steaming southern jungle with a volcano glowing on the horizon"),
    "lvlingqi": ("Lü Lingqi (吕玲绮), Lü Bu's daughter who inherited his halberd — an adult woman",
        "Cool, stoic adult woman in her early 20s with sharp eyes like her father's, long black hair in a high tail.",
        "Red-and-black armor echoing Lü Bu's, a helmet with two long pheasant tail plumes held under her arm.",
        "A smaller version of the Sky Piercer halberd resting on her shoulder.",
        "a windswept northern steppe at dusk with a red horse grazing behind her"),
    "mayunlu": ("Ma Yunlu (马云騄), Ma Chao's younger sister, a Xiliang woman general — an adult woman",
        "Bold, bright-eyed adult woman in her early 20s with a confident smile, long ponytail tied with a silver ring.",
        "Silver lamellar armor trimmed with white fur, a short white cape.",
        "A long lance with a white tassel, reins of a white horse in her other hand.",
        "the Xiliang frontier: dry grassland, a beacon tower and distant snowy mountains"),
    "baosanniang": ("Bao Sanniang (鲍三娘), the heroine of the Bao manor who beat every suitor — an adult woman",
        "Cheerful, athletic adult woman in her 20s with a playful grin and a braid wrapped around her head.",
        "Practical pale-green armor over a red martial robe, arm guards.",
        "A spear spun behind her back in a ready stance.",
        "a country manor's training yard with weapon racks and a few defeated suitors sitting on the ground"),
    "wangyi": ("Wang Yi (王异), the Jicheng heroine who planned the city's defence — an adult woman",
        "Composed adult woman in her early 30s with an unshakeable gaze, hair simply pinned, no jewelry.",
        "Plain dark robe with a leather belt, sleeves bound for work, a wind-torn cloak.",
        "A short sword at her waist, a map of city walls in her hand.",
        "a besieged frontier city wall at dusk with soldiers and smoke"),
    "xinxianying": ("Xin Xianying (辛宪英), the famously perceptive lady of the Xin family — an adult woman",
        "Elegant adult woman in her 20s with clever eyes and a small knowing smile.",
        "Light blue scholar-lady robes with neat layered collars.",
        "Holding a bamboo slip in one hand and a brush in the other.",
        "a quiet study with bamboo scrolls and a window onto a plum tree"),
    "caifuren": ("Lady Cai (蔡夫人) of Jingzhou, Liu Biao's wife and the power behind the Cai clan — a scheming adult woman",
        "Beautiful adult woman in her late 20s with a cold, graceful smile and calculating eyes.",
        "Rich purple silks with gold embroidery, an ornate phoenix hairpin.",
        "A round silk fan half-hiding her face.",
        "a lavish Jingzhou mansion hall with a river view through carved screens"),
    "liubiao": ("Liu Biao (刘表), Governor of Jingzhou and an imperial clansman — a scholar who talks rather than fights",
        "Pale, dignified man around 50 with a long, well-kept black beard, soft hands and a mild, hesitant smile.",
        "Wide-sleeved dark-green scholar-official robes with a black official's cap and a jade pendant at the belt.",
        "Holding a half-unrolled bamboo book of the classics instead of a weapon.",
        "a quiet study in the Xiangyang governor's mansion with shelves of bamboo scrolls and the Han river beyond a lattice window"),
    "caimao": ("Cai Mao (蔡瑁), Lady Cai's younger brother and admiral of the Jingzhou navy — an arrogant, greedy in-law",
        "Burly man in his 40s with a thick moustache, heavy jowls and a sneering, lecherous grin.",
        "An embroidered brocade robe worn over gilded scale armor, a gold belt, rings on his fingers.",
        "One hand on the hilt of a long sword, the other raising a gold beast-shaped wine cup.",
        "the deck of a great tiered warship on the Han river at dusk, rows of Jingzhou war boats behind"),
    "kuaiyue": ("Kuai Yue (蒯越), the far-sighted chief advisor of the Jingzhou gentry",
        "Composed scholar in his early 40s with a neat short beard, a calm, measuring gaze and a faint polite smile.",
        "Immaculate pale-grey Confucian robe with layered collars, a simple black scholar's cap.",
        "Hands folded in a formal bow, a closed folding bamboo scroll tucked into his sleeve.",
        "a lamplit study at night in Xiangyang, a go board with an unfinished game on the low table"),
    "huangzu": ("Huang Zu (黄祖), the grim veteran Administrator of Jiangxia, Liu Biao's hardest general",
        "Gaunt, weathered man in his 50s with a lined, sour face, grey stubble and cold narrow eyes.",
        "Battered dark iron lamellar armor with a river-green cape, a helmet with a short red plume.",
        "A heavy ghost-head broadsword (鬼头刀) held low at his side.",
        "the misty south bank of the Yu river in autumn, tall reeds and a 黄 banner"),
    "jingzhou_gong": ("a Jingzhou archer (荆州弓手), a soldier card",
        "Young soldier with a sun-browned face and a steady squint.",
        "Light green cloth armor over a short tunic, a reed hat, a quiver of arrows at the hip.",
        "Drawing a longbow, crouched in reeds.",
        "a reed marsh on the Han river bank in autumn"),
    "jingzhou_shuijun": ("a Jingzhou marine (荆州水军), a soldier card",
        "Broad-shouldered river sailor with a shaved head and a rough grin.",
        "Bare-chested under a short leather vest, a red headband, rope at the waist.",
        "A boarding pike and a round rattan shield.",
        "the prow of a Jingzhou war boat on the Han river, oars and flags"),
    "bianfuren": ("Lady Bian (卞夫人), a former singer of great grace and good sense — the heroine of the northern start, an adult woman",
        "Graceful adult woman around 30 with warm eyes and a calm, shrewd smile.",
        "Elegant but modest pale rose robes, a simple jade hairpin.",
        "Holding a lantern in the snow, a thick cloak over one arm to share.",
        "a snowy northern plain outside the town of Qiao at night"),
    "yanfuren": ("Lady Yan (严夫人), Lü Bu's stern, practical wife — an adult woman",
        "Handsome, strong-willed adult woman in her 30s with a stern frown and arms crossed.",
        "Sturdy dark red robes of a general's wife, sleeves tied back.",
        "A household ledger tucked under one arm.",
        "the courtyard of a general's residence with a halberd rack"),
    "liniang": ("Li Niang (黎娘), queen of a Shanyue mountain tribe in Jiangdong — an adult woman",
        "Fierce adult woman in her mid-20s with sharp eyes, blue tribal tattoos on her arms and cheek, hair cropped at the shoulders.",
        "Hide and woven-bark armor, bead necklaces, bare feet wrapped in cloth.",
        "A bamboo bow with poison arrows, a quiver of green-fletched shafts.",
        "misty Jiangdong mountains with bamboo forests and stilt houses"),
    "gaoshun": ("Gao Shun (高顺), Lü Bu's grim, silent commander of the Trap-Breaking Camp (陷阵营)",
        "Stern, dark-faced man in his 30s, jaw set, eyes that never blink; utterly still.",
        "Heavy black lamellar armor, plain and unadorned, a tall rectangular shield.",
        "Standing like a post, shield planted, a long ji in his other hand."),
    "xunyou": ("Xun You (荀攸), a quiet strategist just freed from Dong Zhuo's prison",
        "Lean, calm scholar in his mid-30s with a thin beard and patient, unreadable eyes.",
        "A worn dark-blue scholar's robe, slightly rumpled from prison, neatly tied anyway.",
        "Holding a single go stone between two fingers, a go board tucked under his arm."),
    "zhongyao": ("Zhong Yao (钟繇), the great calligrapher, a Gentleman of the Yellow Gate close to the boy emperor",
        "Refined official in his early 40s with a neat beard and ink-stained fingertips, gentle but sharp eyes.",
        "Dark court robes with a black official's cap.",
        "Holding a large brush over an unrolled edict, the characters crisp and elegant."),
    "xiandi": ("Emperor Xian of Han (汉献帝 刘协), the boy emperor, a puppet in Dong Zhuo's hands — a child of about ten",
        "A slight boy of about ten with a pale, serious face and quiet, watchful eyes older than his years.",
        "Black-and-red imperial robes too big for him and a heavy mianliu crown with bead curtains.",
        "Sitting very straight on a huge throne, small hands gripping the armrests."),
    "zhujun": ("Zhu Jun (朱儁), the veteran Han General of Chariots and Cavalry, Sun Jian's old commander",
        "Upright old general in his late 50s with a grizzled grey beard, a hearty laugh and a ramrod-straight back.",
        "Worn but well-kept Han general's lamellar armor with a faded red cloak.",
        "One hand on his sword hilt, the other raised in a big, hearty wave."),
    "huangfusong": ("Huangfu Song (皇甫嵩), the great Han general who crushed the Yellow Turbans, now humiliated at Dong Zhuo's court",
        "Dignified, silent old general around 60, white hair and beard neatly bound, a stern and unbending gaze.",
        "A plain dark court robe over armor, a general's seal cord at the waist.",
        "Standing perfectly straight, both hands resting on a long sword planted point-down before him."),
    "fanchou": ("Fan Chou (樊稠), a loud, brash Xiliang general",
        "Burly man in his 30s with a wild beard and a mocking grin.",
        "Dented Xiliang lamellar armor with fur trim.",
        "Hefting a huge broad saber over his shoulder."),
    "zhangji": ("Zhang Ji (张济), a steady, reserved Xiliang general",
        "Calm man in his 40s with a trimmed beard and patient eyes.",
        "Neat dark Xiliang armor.",
        "Holding a long spear upright, making a polite martial salute."),
    "niufu": ("Niu Fu (牛辅), Dong Zhuo's son-in-law and Dong Bai's uncle",
        "Heavy-set man in his 40s with a hard, jealous glare.",
        "Rich Xiliang general's armor with gold studs.",
        "Gripping a heavy saber, pointing it at the viewer in challenge."),
    "huzhen": ("Hu Zhen (胡轸), a grim Xiliang general guarding the chancellor's inner gate",
        "Grim, scarred man in his 30s.",
        "Black armor, a red sash.",
        "Barring a gate with a drawn broad saber."),
    "dongzhuo": ("Dong Zhuo (董卓), the tyrant chancellor who burned Luoyang",
        "Enormously fat, heavy-jowled man in his 50s with a thick beard, small cunning eyes and a jovial smile that never reaches them.",
        "Extravagant purple-and-gold chancellor's robes straining over his belly, a jeweled belt.",
        "Holding a wine cup in one hand, the other resting on a sword hilt."),
    "caiyong": ("Cai Yong (蔡邕), the great scholar and calligrapher, Cai Wenji's father",
        "Gentle, frail scholar in his late 50s with a long white beard and kind, tired eyes.",
        "Plain grey scholar's robe and a scholar's cap.",
        "Holding a guqin under his arm and a bamboo scroll."),
    "wangyun": ("Wang Yun (王允), the Minister over the Masses — outwardly righteous, secretly ambitious and cunning",
        "Lean, upright old man in his 60s with neatly combed white hair; a benevolent, righteous face, but a cold, calculating glint in the eyes.",
        "Dark official's robe with the minister's seal cord.",
        "Holding a folded memorial behind his back, standing very straight."),
    "fengfuren": ("Lady Feng (冯夫人), Yuan Shu's favourite and very beautiful consort (not his wife) — a scheming villain, an adult woman",
                  "Adult woman in her late 20s of striking beauty, a sweet smile that doesn't reach her cold, calculating eyes.",
                  "Luxurious pale-gold silk robes and a jeweled hairpin — elegant, never gaudy.",
                  "Holding a lacquered box of homemade pastries, a small embroidered handkerchief in her other hand."),
    "yahuan": ("a household maid (丫鬟) of the Sun family, an adult woman",
        "Adult woman in her 20s with a round, cheerful face and a shy smile, hair in two simple buns.",
        "Plain light-green servant's dress with an apron.",
        "Carrying a tea tray with cups, curtsying."),
    "chuniang": ("an army cook (厨娘), an adult woman",
        "Sturdy, cheerful adult woman in her 30s with rosy cheeks and strong forearms.",
        "Rolled sleeves, a flour-dusted apron, a cloth tied over her hair.",
        "Holding a big cleaver in one hand and a steaming pot of braised pork in the other."),
    "xiuniang": ("an embroiderer (绣娘) who mends armor and stitches banners, an adult woman",
        "Graceful adult woman in her 20s with focused eyes and a needle held in her lips.",
        "Neat blue dress, a pincushion on her wrist.",
        "Stitching a large red banner with the character 孙 across her lap."),
    "huansha": ("a riverside washerwoman (浣纱女), an adult woman",
        "Lively adult woman in her 20s with a bright laugh, sleeves rolled high.",
        "Simple hemp dress, barefoot by the water.",
        "Holding a wooden washing bat over her shoulder, a basket of cloth at her side."),
    "caisang": ("a mulberry-leaf picker (采桑女), an adult woman",
        "Healthy, sun-kissed adult woman in her 20s with a gentle smile.",
        "Country dress with a straw hat hanging on her back.",
        "Carrying a bamboo basket full of mulberry leaves."),
    "chaniang": ("a Jiangdong teahouse keeper (茶娘), an adult woman",
        "Sharp-eyed, confident adult woman in her 30s with a sly smile.",
        "Smart dark-red dress with a white apron, a jade hairpin.",
        "Pouring tea from a long-spouted kettle with a flourish."),
    "lusu": ("Lu Su (鲁肃), a generous, far-sighted young gentleman of Jiangdong who once gave Zhou Yu half his granary",
        "Round-faced, kind man in his late 20s with a calm smile and a neat short beard.",
        "Fine but plain scholar-gentleman robes in deep blue, a jade pendant at the belt.",
        "Gesturing toward a large granary behind him, a sack of grain at his feet."),
    "zhangzhongjing": ("Zhang Zhongjing (张仲景), the Sage of Medicine, who served as governor of Changsha",
        "Thin, serious man in his 40s with a long grey-streaked beard and thoughtful eyes.",
        "Official's robe with the sleeves rolled up, a physician's satchel across the chest.",
        "Holding an open bamboo-slip medical book in one hand and a bundle of herbs in the other."),
    "dongfeng": ("Dong Feng (董奉), the Jiangdong doctor of the apricot grove legend",
        "Gentle, ageless-looking man in his 30s with a serene smile.",
        "Simple Taoist-style physician robes in light green, a straw hat on his back.",
        "Standing under a blossoming apricot tree, a medicine gourd at his hip."),
    "zhangzhao": ("Zhang Zhao (张昭), the stern chief steward of the Sun household",
        "Stern, upright man in his 30s with a severe frown and a well-kept beard.",
        "Dark formal official robes and cap.",
        "Holding a thick stack of ledgers and a writing brush, looking disapprovingly at the viewer."),
    "xiaoqiao": ("Xiao Qiao (小乔), the younger of the famous Qiao sisters, an adult woman",
        "Adult woman in her 20s, lively bright eyes and a playful smile, hair in an elegant bun with flowers.",
        "Pink-and-white layered Han dress with flowing sleeves.",
        "Playing a guqin on her lap."),
    "zhenmi": ("Zhen Mi (甄宓), the renowned beauty later celebrated as the Goddess of the Luo River, an adult woman",
        "Adult woman in her 20s, graceful and melancholy, long flowing black hair.",
        "Flowing pale-blue silk robes with gauzy ribbons drifting as if underwater.",
        "Holding a jade hairpin, standing by a misty river."),
    "bulianshi": ("Bu Lianshi (步练师), a gentle, capable lady of Jiangdong, an adult woman",
        "Adult woman in her 20s with a soft, kind face and calm eyes.",
        "Elegant lavender Han dress, a simple hairpin.",
        "Carrying a lacquered tray with medicine bowls and bandages."),
    "qiaoguolao": ("Qiao Guolao (乔国老), the fussy old father of the Qiao sisters",
        "Plump, cheerful old man in his 60s with a long white beard and rosy cheeks.",
        "Rich brocade robes of a retired gentleman.",
        "Hugging a dowry chest overflowing with silks, looking both proud and reluctant."),
    "huofu": ("an army cook (伙夫)",
        "Burly, cheerful adult man with a bald head and a thick mustache.",
        "Stained apron over a soldier's tunic.",
        "Stirring a huge cauldron with a long ladle."),
    "chuangong": ("a Jiangdong boatman (江东船工)",
        "Wiry, sun-browned adult man with a headband and rolled trousers.",
        "Simple hemp clothes, barefoot.",
        "Carrying a long punting pole and a coil of rope over his shoulder."),
    "caiwenji": ("Cai Wenji (蔡文姬, Cai Yan), the gifted poet and musician, daughter of the scholar Cai Yong",
                 "Adult woman in her 20s, gentle but steady eyes with a quiet sorrow, long black hair half tied with a white ribbon.",
                 "Plain white scholar's robe with pale blue trim, a little dusty from the road.",
                 "Holding a guqin (古琴) to her chest; one of its strings is broken.",
                 "A quiet, candlelit ancient scholar study with unrolled bamboo scrolls on low tables, a bronze incense burner emitting delicate fragrant smoke ribbons, and a painted silk partition screen"),
    "yuanshu": ("Yuan Shu (袁术), the arrogant warlord of Nanyang who dreams of becoming emperor",
                "Plump, pale man in his 30s with a thin mustache, heavy-lidded eyes full of contempt, a self-satisfied sneer.",
                "Gaudy gold-embroidered imperial-yellow robes he has no right to wear, a jeweled crown, rings on every finger.",
                "Reaching out with one greedy hand as if for the jade seal, a cup of honey water in the other.",
                "An opulent imperial audience chamber in Nanyang with carved lacquered dragon pillars, gilded screens, hanging yellow-gold imperial tapestries, and a jade throne"),
    "jiling": ("Ji Ling (纪灵), Yuan Shu's foremost general",
               "Tall, grim man in his 30s with a hard square face, thick eyebrows and a short beard.",
               "Heavy gilded lamellar armor with the character 袁 on the chest plate, a red cape.",
               "Wielding a three-pointed double-edged glaive (三尖两刃刀).",
               "A massive army encampment with towering yellow Yuan-clan war banners fluttering in the wind, rows of wooden barracks, and spear racks"),
    "leibo": ("Lei Bo (雷薄), one of Yuan Shu's cavalry commanders",
              "Wiry, sharp-nosed man in his 30s with a cruel grin and a scar across his chin.",
              "Light cavalry armor in Yuan yellow and black, a fur-trimmed collar.",
              "Mounted, swinging a curved cavalry saber, a bow on his back.",
              "A dusty frontier cavalry camp with horse corrals, yellow command flags, and camp tents under a glaring afternoon sun"),
    "chenlan": ("Chen Lan (陈兰), Yuan Shu's veteran general who leads the night raid",
                "Weathered, stubborn man in his 40s with a grey-streaked beard and narrowed eyes.",
                "Battered iron armor under a rain cape, mud on his boots.",
                "Levelling a long spear, rain dripping from its tip, torchlight behind him.",
                "A rain-swept night battlefield with burning barricades, muddy palisade fences, and flickering torches in the drizzling rain"),
    "qiaorui": ("Qiao Rui (桥蕤), a stout officer of Yuan Shu who spies on the Sun household",
                "Short, round-bellied man in his 30s with a sly smile and small shrewd eyes.",
                "Plain officer's armor over a merchant-style robe (he is in disguise), a straw hat hanging on his back.",
                "A heavy broad saber resting on his shoulder.",
                "A bustling ancient market street outside Nanyang city gate, with merchant carts, tiled roofs, hanging red lanterns, and market stalls"),
    "chenwu": ("Chen Wu (陈武), a loyal Jiangdong general from Lujiang who followed Sun Ce",
               "Sturdy, tanned man in his late 20s, square jaw, short beard, calm steady eyes of a marksman.",
               "Jiangdong red-and-brown lamellar armor, a quiver of red-fletched arrows on his back, a leather bracer.",
               "Drawing a large recurved war bow to full draw, arrow aimed past the viewer.",
               "A Jiangdong fortress rampart overlooking the misty Yangtze River, with red Sun-clan banners, wooden archery targets, and distant patrol boats"),
    "jiangdong_gong": ("a Jiangdong archer (江东弓手), a common soldier of the Sun family's army",
                       "Young adult soldier with a sun-browned face and a focused squint, headband.",
                       "Simple red Han tunic over light leather armor, straw sandals, quiver at the hip.",
                       "Nocking an arrow on a plain wooden bow.",
                       "A Sun family army training ground and riverside camp with red flags, wooden archery butts, weapon racks, and barracks tents"),
    "liehu": ("a mountain hunter (山中猎户) from the hills around Fuchun who joined the army",
              "Weathered, lean adult man in his 30s with a scruffy beard and a friendly grin.",
              "Fur vest over rough hemp clothes, a boar-tusk necklace, a pheasant hanging from his belt.",
              "A hunting bow slung ready, one arrow held between his fingers.",
              "A misty Fuchun mountain forest with tall pine trees, green bamboo thickets, mossy boulders, and distant layered mountain ridges"),
    "yuenv_gong": ("a Yue woman archer (越女弓手), an adult woman of the southern Yue people serving as an archer",
                   "Adult woman in her 20s, confident sharp eyes, tanned skin, hair in a high braided ponytail with a red cord.",
                   "Close-fitting indigo Yue-style tunic with embroidered hems and leather arm guards, short practical skirt over trousers.",
                   "Drawing a slim bamboo bow, arrow at her cheek.",
                   "A misty subtropical bamboo grove with a crystal mountain stream, wild mountain flowers, and steep verdant green cliffs"),
    "shanyue_nu": ("a Shanyue crossbowman (山越弩手), a hill-tribe fighter from the mountains of Jiangdong",
                   "Stocky adult man with tattooed arms and cheeks, fierce stare, hair tied up with a bone pin.",
                   "Rattan-and-hide armor, cloth leggings, bare feet planted on a rock.",
                   "Aiming a heavy wooden crossbow braced against his shoulder.",
                   "A rugged Shanyue mountain fortress with heavy timber stockades, rock crags, tribal bone totems, and mountain mist"),
    "zhangfei": ("Zhang Fei (张飞), the legendary fierce powerhouse general from the Three Kingdoms era",
                 "Massive, dark-skinned muscular powerhouse warrior in his early 30s. Fierce round panther-like eyes with an intense battle glare, thick bristling black beard and mustache, roaring at the top of his lungs with explosive, terrifying battle fury (wide open mouth yelling a war cry).",
                 "Rugged Han dynasty black iron plate armor over a deep green battle tunic, heavy spiked shoulder guards, thick leather belt with a bronze tiger buckle.",
                 "Gripping his legendary Zhangba Snake Spear (丈八蛇矛 - an ancient long spear with an undulating, serpentine wavy steel spearhead) thrusting forward dynamically.",
                 "A battle-ravaged camp with dust clouds, broken wagons, flaming braziers, and billowing war banners"),
    "liubei": ("Liu Bei (刘备), the humble, earnest leader who calls himself a descendant of the Prince of Zhongshan",
               "Gentle-faced man in his early 30s with notably large earlobes and long arms, kind sincere eyes, neat short beard, a slightly awkward, eager-to-please smile.",
               "Modest green-and-cream Han scholar-general robe over light leather armor, a simple topknot with a cloth band.",
               "Holding his twin swords (双股剑) a little clumsily in both hands, as if not quite sure how to use them.",
               "A modest Han military garrison headquarters with a tactical map table, candle lanterns, rolled bamboo scrolls, and straw partitions"),
    "guanyu": ("Guan Yu (关羽), the dignified god of war of the Three Kingdoms era",
               "Tall imposing man in his early 30s with a deep red face, phoenix eyes half-closed in calm pride, a magnificent long flowing black beard reaching his chest.",
               "Green war robe over Han dynasty lamellar armor, green headscarf, a heroic cape.",
               "Holding the Green Dragon Crescent Blade (青龙偃月刀 - a long glaive with a dragon-headed crescent blade) upright beside him.",
               "A solemn military command post with green banners, heavy weapon stands, and dramatic evening clouds in the sky"),
    "lvbu": ("Lü Bu (吕布), the unrivaled, terrifying warrior of the Three Kingdoms era",
             "Tall, handsome, arrogant warrior in his early 30s with a cold predatory glare and a confident smirk, overwhelming aura.",
             "Ornate crimson and black armor with gold trim, a helmet crowned with two long pheasant tail feathers (雉尾冠), a red cape flaring behind him.",
             "Holding the Sky Piercer halberd (方天画戟 - a long halberd with a crescent side blade) across his shoulders.",
             "A scorched, dust-swept battlefield under a dramatic crimson and dark sky, with broken weapons stuck in the ground and distant fortress ramparts"),
    "huatuo": ("Hua Tuo (华佗), the legendary wandering physician of the Three Kingdoms era",
               "Lean middle-aged man with a calm, sharp gaze, a thin goatee, sleeves rolled up like a working doctor.",
               "Plain grey-blue traveling robe, a wooden medicine chest on his back painted with the characters 沛国华佗.",
               "Holding a silver acupuncture needle between his fingers; a small hand axe peeks out of the medicine chest (his brain-surgery joke).",
               "A rustic apothecary clinic and traveling medical pavilion with hanging bundles of dried medicinal herbs, an herb-grinding mortar, and medicine drawers"),
    "yuji": ("Yu Ji (于吉), the eerie Taoist priest of Jiangdong",
             "Middle-aged Taoist with a thin mustache and an unsettling, knowing smile, narrowed eyes.",
             "Flowing white Taoist robe, hair in a topknot with a wooden pin.",
             "Holding a tall cloth banner reading 「于吉仙师 符水治百病」 with a single copper coin dangling from it.",
             "A mystical mountain stone altar shrouded in swirling incense smoke, yellow Taoist talisman streamers fluttering in the wind, and ancient pine trees"),
    "fushui_xintu": ("a fanatical follower of the Taoist charm-water cult (符水信徒)",
                     "Gaunt peasant with feverish devoted eyes, a yellow paper talisman stuck on the forehead.",
                     "Ragged brown peasant clothes, a yellow cloth sash.",
                     "Holding out a bowl of murky charm water with both hands, pressing it forward insistently.",
                     "A rural village temple courtyard crowded with devoted peasants, incense smoke, and yellow Taoist charm banners tied to wooden poles"),
    "baie_hu": ("a giant white-browed tiger (吊睛白额虎) from Chinese legend",
                "Enormous fierce tiger with slanted glaring eyes and a white patch on its brow, muscles rippling.",
                "Wearing a simple leather war saddle (it can be ridden as a mount).",
                "Crouched and snarling, about to pounce, claws out.",
                "A wild mountain cliff among ancient twisted pine trees, jagged rocks, and swirling mountain fog"),
    "boar": ("a huge wild boar (野猪)",
             "Massive bristly dark-brown boar with long curved tusks and small angry red eyes.",
             "No clothing; mud splashed on its flanks.",
             "Head lowered, charging straight at the viewer.",
             "A deep primeval forest clearing with thick moss, muddy soil, gnarled tree roots, and tangled briars"),
    "lijue": ("Li Jue (李傕), the brutal Xiliang general who burned Luoyang",
              "Heavy-set, cruel-faced man in his 30s with a scarred cheek, thick stubble and a sneer.",
              "Dark Xiliang iron scale armor with fur trim, a horsehair-crested helmet.",
              "A flaming torch in one hand and a saber in the other, fire and smoke behind him.",
              "The burning gates and streets of Luoyang at night, with blazing imperial palaces, billowing black smoke, and glowing embers in the night sky"),
    "chengpu": ("Cheng Pu (程普), the eldest veteran general under Sun Jian",
                "Kindly, dignified veteran in his 40s with a long beard and a warm smile.",
                "Well-worn bronze lamellar armor over a dark red tunic.",
                "Holding the iron-spined snake spear (铁脊蛇矛), bowing slightly with one hand raised in greeting.",
                "A seasoned Jiangdong army headquarters with red banners, heavy wooden stockades, and Sun-clan tiger standards"),
    "handang": ("Han Dang (韩当), Sun Jian's silent horse-archer general",
                "Expressionless, weathered man in his 30s with sharp hawk-like eyes and a short beard.",
                "Light leather cavalry armor, a quiver of arrows at his hip.",
                "Mounted on a horse, drawing a large bow.",
                "An open reed marsh and riverbank along the Yangtze with grazing warhorses, wooden piers, and river mist"),
    "huanggai": ("Huang Gai (黄盖), Sun Jian's tough veteran general",
                 "Burly veteran in his 40s with a booming laugh, grey-streaked beard, chest covered in old scars.",
                 "Heavy armor with the robe pulled open to show off his scars.",
                 "Holding an iron whip (铁鞭), slapping his chest proudly.",
                 "The wooden deck of a Jiangdong war galley on the Yangtze River, with heavy ship bulwarks, coiled ropes, and rolling river waves"),
    "zhuzhi": ("Zhu Zhi (朱治), Sun Jian's shrewd quartermaster general",
               "Sharp, composed man in his 30s with a neat mustache and an appraising look.",
               "Official's robe over light armor, a sword at his waist.",
               "Holding a supply list scroll in one hand and a writing brush in the other.",
               "An orderly army granary and logistics warehouse with stacked rice sacks, supply carts, accounting scrolls, and ledger chests"),
    "wujing": ("Wu Jing (吴景), Lady Wu's protective younger brother",
               "Handsome general in his 30s whose features resemble his elder sister's, a short neat beard, a suspicious, protective frown.",
               "Bright silver cavalry armor and a white cape.",
               "Riding a white horse, gripping the reins and glaring at the viewer.",
               "A Sun family courtyard and military stable with sleek cavalry horses, wooden gates, and fluttering silk pennants"),
    "sunben": ("Sun Ben (孙贲), Sun Jian's competitive nephew",
               "Young spear general in his 20s with a cocky smirk, arms crossed.",
               "Red and bronze Sun-clan armor.",
               "Hugging a spear against his shoulder, looking unimpressed.",
               "A military training courtyard with wooden practice dummies, weapon racks, and earthen ramparts"),
    "sunjing": ("Sun Jing (孙静), Sun Jian's stingy younger brother who keeps the family home",
                "Thin older man in his 40s with squinting eyes and a thin mustache, a miserly expression.",
                "Plain grey household robe and a cap.",
                "Flicking the beads of an abacus, peering over it suspiciously.",
                "A Sun clan estate counting room and storehouse with heavy iron-bound chests, stacked bamboo tax records, and abacus desks"),
    "tangji": ("Lady Tang (唐姬), the widowed consort of the deposed young emperor",
               "An adult woman in her twenties with graceful noble bearing, soot smudged on her cheek, steady unyielding eyes.",
               "Plain coarse cloth dress that cannot hide her dignity, hair loosely tied.",
               "Clutching a jade hairpin to her chest.",
               "A desolate ruined palace hall in burned Luoyang, with blackened wooden pillars, crumbling brick walls, and moonlight shining through broken ceiling tiles"),
    "yanzhihu": ("'Rouge Tiger' (胭脂虎), the fierce bandit queen of a mountain fort",
                 "A curvy adult woman in her thirties with a bold, teasing grin, fiery eyes and a confident swagger.",
                 "Red bandit leather vest and trousers, a sash at the waist, bangles.",
                 "Hands on hips with twin sabers tucked in her sash, standing on a fort wall.",
                 "The timber watchtower and palisade gate of a mountaintop bandit fortress, with red festival lanterns, tiger pelt banners, and scenic mountain peaks"),
    "huangjin_nvyi": ("a Yellow Turban field medic (黄巾女医)",
                      "An adult woman in her twenties, calm and capable, sleeves rolled up.",
                      "Yellow headscarf, simple brown clothes, a medicine chest painted with Taiping Taoist charms.",
                      "Bandaging a wounded arm, looking up at the viewer.",
                      "A makeshift field hospital tent with straw pallets for the wounded, steaming herb cauldrons, and yellow talisman banners"),
    "gongnv": ("a palace maid fleeing the burning Luoyang (宫女)",
               "An adult woman in her twenties, frightened but resolute.",
               "Han dynasty palace dress with a soot-blackened hem.",
               "Holding a lantern and a small medicine box.",
               "A burning palace corridor during the fall of Luoyang, with collapsing gilded beams, red sparks, and smoky archways"),
    "xiliang_nvbing": ("a Xiliang female cavalry guard (西凉女亲兵)",
                       "An adult woman in her twenties, fierce and loyal, high ponytail.",
                       "Fitted Xiliang leather armor with fur trim.",
                       "Mounted, a curved saber raised.",
                       "A windswept northwestern mountain pass with rocky cliffs, Xiliang wolf-head banners, and distant desert hills"),
    "guosi": ("Guo Si (郭汜), the raiding Xiliang general",
              "Wiry, greedy-looking man in his 30s with a crooked grin.",
              "Xiliang cavalry armor with looted jewelry hanging from it.",
              "Holding a long lance (马槊) and a sack of loot.",
              "A plundered and burning frontier village with smoking wooden houses, broken fences, and Xiliang raiding flags"),
    "liru": ("Li Ru (李儒), Dong Zhuo's scheming strategist",
             "Pale, thin man in his 30s with cold calculating eyes and a thin smile.",
             "Dark purple scholar's robe.",
             "Holding a cup of poisoned wine (鸩酒) in one hand, a folding fan in the other.",
             "A dim, candlelit chancellor's inner sanctum with dark purple silk curtains, bronze incense burners, secret scrolls, and heavy shadows"),
    "feixiong_bing": ("a Flying Bear elite heavy cavalryman (飞熊军) of Dong Zhuo's guard",
                      "Massive faceless soldier behind a bear-shaped visor.",
                      "Full black heavy armor with bear-fur trim.",
                      "Mounted on an armored warhorse, lance lowered.",
                      "A grim Xiliang vanguard cavalry line on a vast windswept plain, with dark heavy banners and distant mountain ranges"),
    "xiliang_bing": ("a Xiliang light cavalry raider (西凉铁骑)",
                     "Rugged frontier horseman in his 20s with windburned skin.",
                     "Leather and iron cavalry gear, a fur hat.",
                     "Galloping, saber drawn.",
                     "A dusty frontier mountain road with dry brush, rocky cliffs, and galloping horse tracks under a pale sky"),
    "shanzei_bing": ("a one-eyed mountain bandit (山贼)",
                     "Scruffy bandit with an eye patch and a gap-toothed leer.",
                     "Ragged patched clothes, a rope belt.",
                     "Carrying a big wood axe over his shoulder.",
                     "A winding mountain pass with a rough timber stockade gate, spiked wooden barricades, and jagged rocky cliffs"),
    "inf_n": ("a Han dynasty government sword-and-shield soldier (官军刀兵)",
              "Disciplined, stern-faced soldier in his 20s.",
              "Standard Han army lamellar armor and helmet.",
              "Sword raised behind a round shield.",
              "A Han dynasty garrison camp courtyard with earthen ramparts, wooden watchtowers, and red military flags"),
}

# battle scenario id: the scene (the enemy in its setting, Rance X style)
BATTLES = {
    "c3_mitan": "a tavern back alley at night: Yuan agents in plain clothes drawing short knives from their sleeves",
    "c3_qibing": "a rainy night road: Yuan cavalry with spears charging out of the dark, rain slanting in the torchlight",
    "c4_liumin": "the ruins of Luoyang: a desperate mob of starving refugees with hoes and sticks surging over rubble toward the grain carts",
    "c5_qinbing": "a lotus garden at night: Lü Bu's Bingzhou guards with ji searching between the pavilions with lanterns",
    "c6_fubing": "a long Chang'an street before dawn: Wang Yun's house troops in a line with ji and crossbows",
    "c6_xianzhen": "the square before the Xuanping Gate in snow: black-armored Trap-Breaking Camp infantry behind tall shields",
    "c2_gongqi": "a side path between wheat fields: Xiliang horse archers wheeling around and loosing arrows, fire arrows streaking",
    "c3_xunluo": "outside a walled town in Nanyang: a Yuan army patrol with spears under a 袁 banner blocking a country road",
    "c3_gongshou": "a fork in a road lined with trees: Yuan archers kneeling behind a low earth bank, bows drawn, a 袁 banner",
    "biwu": "a village fighting-for-a-husband stage hung with red silk: Bao Sanniang (adult) in pale-green armor twirling her spear with a cheeky grin, a row of defeated suitors rubbing their backs at the edge, a cheering crowd below",
    "c4_gaoshun": "the back gate of a scholar's mansion in Chang'an before dawn, the house burning behind: the grim, dark-faced Gao Shun standing like a post behind a wall of tall black shields bristling with halberds, his Trap-Breaking Camp utterly silent",
    "c4_langqi": "a long Chang'an street at dawn, lanterns smashed: Bingzhou wolf riders in fur-trimmed armor galloping straight at the viewer, sabers raised, their leader howling",
    "c4_lvbu": "the great Xuanping Gate of Chang'an in falling snow at dawn: Lü Bu on the rearing Red Hare with his halberd raised high, Gao Shun's black shield wall behind him; a woman in a black cloak (Diaochan, adult) seated behind his saddle looking away",
    "c6_shaoka": "the Qingming Gate of Chang'an at night: a row of torches, Han guards in red and black with halberds barring the road, their officer holding out a written order",
    "c6_fanchou": "a narrow mountain road east of Chang'an: the loud, brash Xiliang general Fan Chou on horseback swinging a huge saber, laughing, Xiliang cavalry pouring down the slope",
    "c6_lijue": "Hangu Pass at sunset: the gaunt, cruel Li Jue on horseback before a huge 李 banner, his blade still stained, rows of Xiliang cavalry filling the pass behind him",
    "c7_qiaorui": "a Yuan army camp gate in Nanyang in summer: the stout Qiao Rui tossing away a chicken bone and drawing his broad saber, Yuan soldiers scrambling out of their tents",
    "c7_leibo": "a mountain road outside Wancheng: Lei Bo with a scar on his chin leading light cavalry in a charge, arrows in the air",
    "c7_chenlan": "the walls of Wancheng in Nanyang: the grey-bearded general Chen Lan on the gate tower pointing a long spear down, archers along the battlements, the 袁 banner above",
    "c7_jiling": "the west gate of Wancheng at dawn, smoke rising in the city behind: Ji Ling alone on horseback in gilded armor with his three-pointed double-edged blade, holding the gate while Yuan Shu's carriages flee behind him",
    "jx_bubing": "the north bank of the Yu river in autumn: a line of Jingzhou infantry with round shields painted 刘 and a forest of spears, having just waded across, reeds behind them",
    "jx_gongshou": "a reed marsh along the Yu river: Jingzhou archers half-hidden in tall reeds loosing a volley across the water",
    "jx_huangzu": "the south bank of the Yu river under a big 黄 banner: the gaunt grey veteran Huang Zu on horseback raising his ghost-head broadsword, Jingzhou troops and river boats behind him, arrows in the air",
    "jx_shuijun": "a Jingzhou river fortress on the Han river: bare-chested Jingzhou marines leaping from a line of war boats onto the jetty with pikes and rattan shields, a huge tiered flagship behind",
    "jx_nushou": "inside a burning lakeside pavilion full of smoke: Cai family crossbowmen behind torn silk curtains shooting blindly into the haze, an overturned bronze brazier spilling embers",
    "jx_caimao_a": "a half-burnt banquet pavilion on a rock above the Han river: the burly Cai Mao clutching his bleeding right eye with one hand and swinging a long sword with the other, death-sworn guards around him, flames and smoke",
    "jx_caimao_b": "a moonlit banquet pavilion on a rock above the Han river, overturned tables: the burly Cai Mao in brocade over gilded armor cornered at the railing with his sword drawn, his last guards around him, crossbows now aimed at him from the curtains",
    "c5_fanchou": "a courtyard duel ring at a feast: Fan Chou swinging a huge saber, laughing Xiliang officers cheering from the tables",
    "c5_zhangji": "a courtyard duel ring at a feast: the steady Zhang Ji with his spear levelled, lantern light",
    "c5_niufu": "a courtyard duel ring at a feast: Niu Fu charging with a heavy saber, Dong Bai standing up at the table shouting, Dong Zhuo watching with narrowed eyes",
    "c5_huzhen": "the chancellor's inner gate at night: Hu Zhen barring the way with a broad saber as the great doors swing shut behind him",
    "c4_guosi": "a looted village road: Guo Si on horseback over captured grain carts, soldiers loading the villagers' last sacks, an old man knocked down, Dong Bai smashing a cart wheel with her twin hammers",
    "c5_hall": "a wedding hall turned trap: red lanterns and silk, the doors slammed shut, black-armored Flying Bear cavalry pouring in from behind the curtains",
    "c5_dongzhuo": "the steps before the chancellor's mansion at night: the enormous Dong Zhuo with a drawn sword among his elite black-armored guards, wedding lanterns burning behind him",
    "dagu": "the Dagu pass outside Luoyang: the veteran Xiliang general Xu Rong on horseback before rows of heavy cavalry and spearmen in battle formation, dust and banners, an ambush glinting in the hills",
    "c3_shanfei": "a one-eyed bandit chief on horseback dragging a woman in white onto his saddle amid fleeing refugees on a dusty road, a broken guqin on the ground",
    "c3_qiaorui": "outside the Nanyang city wall at dusk: the stout officer Qiao Rui with Yuan soldiers in disguise stepping out of a market crowd, sabers drawn",
    "c3_jiling": "a narrow mountain pass in heavy rain: Yuan Shu's foremost general Ji Ling in gilded armor with a three-pointed glaive, standing alone in front of a wall of spearmen, the final battle",
    "c3_leibo": "a mountain trail at dawn: Lei Bo leading Yuan cavalry in pursuit, arrows flying, mud splashing",
    "c3_chenlan": "a rainy night courtyard lit by torches: the grey-bearded general Chen Lan with a long spear at the gate under a 袁 banner, soldiers pouring in",
    "c3_yuanshu": "a rain-soaked valley mouth: Yuan Shu's golden-roofed carriage behind rows of archers and a huge 袁 banner, overwhelming numbers",
    "boar": "a huge wild boar charging out of a muddy forest clearing full of fallen logs in the hills of Jiangdong",
    "shuizei_scout": "river bandits leaping out of tall riverside reeds at a broken wooden fort gate, brandishing knives",
    "shuizei": "the river bandit chief 'River Dragon' Hu Yu with his twin daggers on the plank walkways of a river fortress over dark water",
    "shuizei_guard": "bandit gate guards at a river fortress, burning boats lighting up the river behind them",
    "shuizei_main": "the Yellow Turban commander He Yi on the deck of a great river fortress, Yellow Turban and bandit banners, fire ships on the water",
    "yaodao": "the Yellow Turban sorcerer Tang Zhou at a smoking altar in front of a fortress, paper talismans swirling, kneeling followers",
    "tiger": "a giant white-browed tiger leaping from rocks on a mountain path among pine trees",
    "yuji_xintu": "fanatical cult followers surging out of a roadside shrine holding bowls of charm water",
    "shanzei_band": "mountain bandits blocking a winding mountain path below a fort wall with a tattered 替天行道 banner",
    "yanzhihu": "the bandit queen 'Rouge Tiger' with twin sabers in the great hall of her fort, decorated with red wedding silk",
    "huangjin_remnant": "Yellow Turban remnants rising up with farm tools in a smoky valley camp",
    "guanjun": "Han government soldiers storming the yard of a ruined temple",
    "xiliang_youqi": "Xiliang light cavalry galloping down a dusty Central Plains road",
    "guosi": "the raider general Guo Si on horseback in a plundered burning village",
    "feixiong": "Dong Zhuo's Flying Bear heavy cavalry in black armor lined up on an open plain",
    "liru": "the strategist Li Ru smiling from a cliff above a narrow gorge while ambushers spring out on both sides",
    "huaxiong": "the giant general Hua Xiong swinging his great blade on an open battlefield, a red headscarf lying in the dust",
    "dongbai": "Dong Bai, an adult woman general, leaping with two giant bronze hammers on a riverbank cratered by her blows",
    "hulao_ch1": "Lü Bu on the red horse Red Hare charging across a desolate plain at night, dust and moonlight",
    "lijue": "Li Jue with a torch in front of the burning gates of Luoyang, flames and smoke",
    "xiliang_scout": "Xiliang soldiers escorting a grain wagon convoy along a mountain foot road",
}

# story cg key: the scene
CGS = {
    "c5_yuexia": "a moonlit garden behind the Minister's mansion, a round moon gate: Diaochan (adult, of great beauty) finishing a silent dance half a step from the hero, long sleeves still drifting in the night wind, an empty wine cup on the stone steps; her smile teasing and unreadable; silver-blue moonlight",
    "c4_mangshan": "dawn on Mount Mang north of Luoyang, mist below: Dong Bai (adult, silver ponytail, purple fur-trimmed riding armor) on a chestnut horse glancing back with red ears after a quick kiss, galloping downhill; the hero on his horse behind her touching his cheek, stunned; the grey city far below in the sunrise",
    "c5_chuxi": "New Year's Eve on the highest roof of the chancellor's mansion in Chang'an: Dong Bai (adult) asleep on the hero's shoulder with half a burnt flatbread in her hand, the hero sitting still and not daring to look down; below, the city glowing with bonfires of crackling bamboo, snow on the tiles",
    "c4_xizi": "lamplight inside a small army tent at night: Cai Wenji (adult, in white) guiding the hero's hand over a brush, her hand over his, both leaning over a sheet of paper with wobbly characters; soft warm glow, tender and shy",
    "c5_snow": "a snowy back veranda of a scholar's house at night: Cai Wenji (adult, in white) playing a guqin on her knees with snow settling on the strings, the hero sitting beside her in a red wedding robe she has just fitted on him; lantern glow, quiet and bittersweet",
    "c7_stars": "a grassy hilltop above an army camp on a summer night under a sky full of low stars: Cai Wenji (adult, in white) playing a guqin across her knees, the short-haired hero lying back in the grass listening",
    "c4_zhujun": "Sun Jian's camp in the ruins of Luoyang: the veteran general Zhu Jun (grey-bearded, straight-backed, hearty laugh) slapping the huge Sun Jian on the shoulder, Sun Jian bowing formally for once; Sun Ce behind them red-faced trying not to laugh",
    "c6_yizu": "the palace steps of Chang'an the day after Dong Zhuo's death: Dong Bai (adult) kneeling numbly on the stone, the short-haired hero standing in front of her with his blade half drawn, the white-haired Huangfu Song stepping to his side; high above, the small boy emperor clutching a pillar",
    "c6_warn": "night at a window in Chang'an: Diaochan (adult) in a black cloak, pale but smiling, leaning in at the hero's window by candlelight; in the neighbouring window Dong Bai slamming her shutters",
    "c4_siege": "before dawn, torches around a scholar's house in Chang'an: the elderly Cai Yong being led away without resisting, looking back; Cai Wenji (adult, in white) reaching after him, held back by the short-haired hero",
    "c4_dongjia": "a ruined roadside shrine at dawn: the door kicked open, Dong Bai (adult) standing in the doorway with her twin hammers, grey-haired veterans only as silhouettes behind her; the hero looking up from the straw",
    "c7_feng": "a lamplit army tent at night: the beautiful Lady Feng (adult) pouring wine for the hero and resting her fingertips on his wrist; at the tent flap Dong Bai (adult) slamming a hammer down and Cai Wenji (adult, in white) with a snapped zither string, both glaring",
    "c8_jiayan": "a family supper in the courtyard of the Wancheng governor's house on an autumn evening: Lady Wu (adult) handing the short-haired hero a big bowl of chicken soup and ruffling his cropped hair; Sun Ce hanging over the edge of the pot trying to snatch meat; warm lantern light",
    "c8_liuxian": "the bank of the Yu river at sunset: Diaochan (adult, of great beauty) in a light pale-jade southern 'liuxian' skirt sitting hugging her knees on the grass, laughing with her hand over her mouth; in the shallows Sun Ce slipping while grabbing at a fish; Zhou Yu on a rock writing in his ledger",
    "c8_caifuren": "a lavish welcome banquet in Xiangyang: Lady Cai (adult, purple gold-embroidered silks, phoenix hairpin) holding Cai Wenji's (adult, in white) hands over an open clan genealogy book, all warm smiles; beside them Diaochan (adult) accepting a box of pearls with an equally sweet smile; the elderly scholar Cai Yong stroking his beard sceptically in the background",
    "c8_shuige": "a lavish pavilion over the Han river, the only door sealed by a fallen iron portcullis, crossbowmen behind the curtains: Diaochan (adult) in a pale-jade skirt draining a gold beast-shaped wine cup before the burly Cai Mao, her other hand already reaching for the hairpin in her hair; the short-haired hero half-rising with his blade half drawn, shouting; tense, no gore",
    "c8_xiangxiao": "the smoking ruin of a pavilion on a rock above the Han river at dawn: the short-haired hero kneeling, holding Diaochan (adult, pale, in a scorched pale-jade skirt) in his arms; she smiles faintly and touches his cropped hair; restrained and elegiac, no gore",
    "c8_henhai": "a cold rainy night on the bank of the Han river: the short-haired hero alone, crouching at the water's edge washing a pale-jade woman's skirt, holding half of a broken hairpin; behind him in the rain a young man in white mourning clothes stepping closer; bleak, restrained, no gore",
    "c8_dress": "a bedroom in the Xiangyang guesthouse in the afternoon: Diaochan (adult) at a bronze mirror in her most beautiful pale-jade skirt embroidered with water patterns; Lady Wu (adult) pinning her hair; the short-haired hero crouching beside her tucking a strand of hair behind her ear; gentle and warm",
    "c8_grapes": "a lamplit banquet pavilion over the Han river: the short-haired hero casually holding Diaochan (adult, blushing, peeling a grape) in one arm and pushing a gold beast-shaped wine cup away with the other hand; across the table the burly Cai Mao going green in the face; the calm scholar Kuai Yue watching; comic and tense",
    "c8_louchuan": "the bow of a great tiered warship on the moonlit Han river: Diaochan (adult) in a pale-jade skirt fluttering in the wind leaning on the short-haired hero's shoulder, a paper packet of hot roasted chestnuts in her hands; a huge full moon over the river, silver ripples",
    "end_henhai": "an ending card illustration, quiet and symbolic: half of a broken jade hairpin and a folded pale-jade silk skirt lying on wet pebbles at the edge of the Han river at night, cold rain on the water, a distant pavilion on a rock burnt black; muted colours, no people, no blood",
    "c7_flee": "the east gate of Wancheng in a cloud of dust: Lady Feng (adult) lifting the curtain of her palanquin as it hurries away behind a few loaded carts and glancing back with a faint smile; the hero watching from the captured wall under a 孙 banner",
    "end_yusui": "an ending card illustration, quiet and symbolic: the Imperial Jade Seal broken into pieces on a wet grey stone by a rainy mountain road, its gold-mended corner lying in the mud, a woman's hairpin beside it; cold rain, muted colours, no people",
    "end_tonggui": "an ending card illustration, quiet and symbolic: three sets of footprints side by side in fresh snow before the closed Xuanping Gate of Chang'an at dawn, a pair of notched bronze hammers and a broken guqin lying together in the snow; soft falling snow, muted colours, no people, no blood",
    "c4_tonggui": "dawn in falling snow before the closed Xuanping Gate of Chang'an, seen from behind: the short-haired hero in battered silver armor, Dong Bai (adult) with her notched twin hammers on his left, Cai Wenji (adult, in white) holding a broken guqin on his right, the three holding hands and stepping forward together; restrained and elegiac, no gore",
    "c6_fenghou": "the throne hall in Chang'an: the ten-year-old boy emperor leaning forward on a huge throne, insisting in a trembling voice; below him the white-haired Wang Yun bowing with a smile that doesn't reach his eyes",
    "c6_escape": "night escape from Chang'an: a covered carriage racing through a burning city gate, the boy emperor peeking out clutching a small bundle; Dong Bai (adult) riding alongside with her twin hammers; the hero riding on the other side with Diaochan (adult) behind his saddle",
    "c6_huihe": "the restored gate of Luoyang at dawn: the huge Sun Jian in his tiger-pelt cape kneeling on one knee in the dust before the small boy emperor stepping down from a battered carriage",
    "c6_seal": "a makeshift throne hall in half-ruined Luoyang: the boy emperor on a simple throne asking quietly; the huge Sun Jian clutching a brocade box against his chest, not offering it; Zhou Yu writing in his ledger with lowered eyes; Lady Wu (adult) watching Sun Jian from the back",
    "c7_huangzhong": "a captured camp in Nanyang: Huang Zhong, a sturdy man in his 40s in rough soldier's clothes, rope marks on his wrists, drawing a heavy bow to full; his arrow snapping the banner pole with the character 袁 on the far camp gate; Sun Ce gaping, the hero grinning",
    "c5_garden": "behind a rockery in the palace garden of Chang'an: the ten-year-old boy emperor, his heavy bead-curtained crown taken off and set on a stone, rubbing his neck and looking up hopefully at the short-haired hero in silver armor, who crouches to his eye level; a eunuch keeps watch at the corner; a gentle, melancholy mood",
    "c5_feast": "a lavish welcome feast in Dong Zhuo's mansion: the enormous Dong Zhuo peeling shrimp for his granddaughter Dong Bai (adult), who laughs with her mouth full; he wipes his eye with his sleeve",
    "c5_dance": "a lantern-lit banquet hall: Diaochan, an adult woman of great beauty, dancing with long silk sleeves; the enormous Dong Zhuo leaning forward spellbound with wine in his beard; Wang Yun at the host's seat with a knowing half-smile",
    "c5_fengyi": "the Phoenix Pavilion in a lotus garden: Diaochan (adult) weeping on Lü Bu's shoulder at the railing; behind them the furious Dong Zhuo hurling Lü Bu's halberd; Lü Bu twisting away; Diaochan's eyes glancing sideways toward the viewer with the ghost of a smile",
    "c5_rescue": "a long street at night: Lü Bu on the rearing Red Hare charging in with his halberd, Diaochan (adult) holding on behind his saddle with bloodied hands, shouting",
    "c4_wenji": "night by a campfire in ruined Luoyang: Cai Wenji, an adult woman in white, holding her guqin with a broken string, telling her story; Dong Bai listening with folded arms, Lady Wu wrapping a cloak around Cai Wenji",
    "c4_peace": "Sun Jian's tent in ruined Luoyang: the envoy Li Ru waving a feather fan and offering peace with a gentle smile; the huge Sun Jian sitting with crossed arms, scowling",
    "c4_betroth": "a comedic betrothal in a tent: the short-haired hero pointing at himself in disbelief; Dong Bai (adult) beside him looking away with bright red ears; Sun Ce leaping up in refusal; Lady Wu (adult) laughing behind her sleeve",
    "c5_enter": "the gates of Chang'an: the enormous Dong Zhuo hugging his granddaughter Dong Bai (adult), who laughs; over her shoulder his smiling eyes are cold; behind him Lü Bu on Red Hare, silent",
    "c5_diaochan": "a moonlit garden: Diaochan, an adult woman of great beauty, kneeling before an incense burner praying to the moon; Wang Yun and the hero watching from the garden gate",
    "c5_dress": "a bedroom in Chang'an: Dong Bai (adult) in a red wedding dress turning happily before a bronze mirror, the hero behind her with a troubled face",
    "c5_wedding": "the wedding trap in a hall of red lanterns: the enormous Dong Zhuo raising his cup with a cruel smile; beside him Dong Bai (adult) in a red wedding dress lifting her veil in shock, the hero pulling her behind him",
    "c5_death": "the moment of mercy, restrained: Dong Bai (adult) in her red wedding dress kneeling with her arms spread wide to shield a fallen figure on the palace steps, looking up at Lü Bu towering on Red Hare with his halberd raised; no gore",
    "c3_feng": "a quiet veranda in Luyang: Lady Wu sewing a winter coat and the beautiful Lady Feng embroidering a handkerchief side by side, laughing over a plate of pastries — Lady Feng's eyes sliding toward a brocade box half-hidden inside",
    "c2_heqin": "a tense army tent: Sun Jian kicking over a marriage-proposal gift box and driving his saber into the table, the envoy Li Jue backing away with a forced smile, young Sun Ce pale with shock, Zhou Yu watching calmly; outside the tent flap a carriage curtain slightly lifted",
    "c2_mixin": "night after a battle: Zhou Yu reading a captured secret letter by torchlight, Sun Jian crushing its edge in his fist, far on the horizon the sky over Luoyang faintly red",
    "c3_leave": "leaving the ruins of burning Luoyang: Sun Jian riding in front hugging a brocade box; Lady Wu (adult) leaning from a carriage to hand bread to a child; a long column of refugees trudging behind them",
    "c3_wenji": "on a muddy road after a fight: Cai Wenji, an adult woman in a white robe, kneeling to pick up her guqin with a broken string, Dong Bai with her twin hammers looking away embarrassed, Lady Wu putting a cloak on Cai Wenji's shoulders",
    "c3_supply": "night in a hungry army camp: Sun Jian alone by a campfire opening and closing a brocade box, Zhou Yu counting on his fingers, Sun Ce hiding his rice bowl behind his back",
    "c3_slip": "a lively tavern full of drinkers: a tipsy Sun Ce slamming the table and bragging, Zhou Yu lunging to cover his mouth, the hero tossing coins on the table; at the next table soldiers in Yuan livery freezing mid-bite",
    "c3_entrust": "lamplit room at night: Sun Jian placing the brocade box with the jade seal into Lady Wu's hands, the hero standing at the doorway, Sun Jian gruffly avoiding his eyes",
    "c3_warn": "the night before the campaign: the hero earnestly pleading with Sun Jian, who laughs and claps him hard on the shoulder, a war banner and armor stand behind them",
    "c3_raid": "a rainy night at a courtyard gate lit by torches: the grey-bearded general Chen Lan with a long spear under a 袁 banner; the short-haired hero barring the way, Lady Wu (adult) behind him clutching a brocade box",
    "c3_news": "a rainy mountain pass: the defeated general Ji Ling kneeling in the mud, leaning on his three-pointed blade; Lady Wu (adult) slowly sinking to her knees in the rain",
    "c3_end": "a restrained tragic scene in the rain on a mountain road: Lady Wu (adult) standing tall and calm, lifting the Imperial Jade Seal high over a grey stone, her face serene; Yuan Shu's golden-roofed carriage only a blur in the background; no gore",
    "c1_wake": "a beautiful mature noblewoman (Lady Wu, adult) leaning over a young man with short modern hair lying in an embroidered bed, pressing a damp cloth on his forehead, lanterns, incense smoke, soft light",
    "c1_bandage": "Lady Wu sitting on the bed rewrapping a bandage on the young man's thigh, a tray with medicine and bandage rolls, the young man bright red with embarrassment, morning light (comedic, non-explicit)",
    "c1_raid": "a night raid: the grinning bandit chief Hu Yu with a headband holding up a torch, the gate of 富春山庄 in flames, river bandits and Yellow Turban men charging with tridents and sabers, a line of torch-lit boats on the river",
    "c1_rescue": "inside a river fortress: the young man holding Lady Wu's hands after untying her ropes from a pillar, Sun Ce coughing loudly behind them",
    "c1_dinner": "a warm family dinner: the young man pretending to be drunk with his head on Lady Wu's lap, Sun Ce snapping his chopsticks in two, Zhou Yu hiding a laugh (comedic)",
    "c1_armor": "Lady Wu fastening the straps of Sun Jian's old silver tiger-engraved armor on the hero, a black cape trimmed with white fur, and a tiger pelt sewn in as the armor skirt's lining, beside an opened camphor chest, Sun Ce gaping at the doorway, Zhou Yu with his ledger",
    "c1_oath": "three young men (the hero, Sun Ce, Zhou Yu) kneeling on a riverbank swearing brotherhood, three chopsticks stuck in the ground as incense, sunset over the river",
    "c1_north": "farewell at the village gate: Lady Wu hugging the young man goodbye, Sun Ce grinding his teeth, a bundle of hand-sewn clothes with a little tiger embroidered on it",
    "c2_zumao": "a battlefield: the veteran Zu Mao wearing a red headscarf being chased by the giant Hua Xiong, the young Sun Ce charging in with a spear",
    "c2_capture": "the hero carrying the unconscious woman general Dong Bai over his shoulder like a sack of rice, Sun Ce and Zhou Yu each struggling to carry one of her giant bronze hammers (comedic)",
    "c2_captive": "inside a prisoner tent: the woman general Dong Bai, an adult woman with her arms loosely tied, playing rock-paper-scissors against the hero, her hand a split second late, a half-eaten bowl of braised pork beside her, Sun Ce peeking in enviously through the tent flap (comedic)",
    "c2_raid": "a burning army camp at night: Sun Jian alone blocking the camp gate with his sword against Lü Bu on the red horse Red Hare",
    "c2_sanying": "the legendary three heroes fighting Lü Bu in a storm of dust: Lü Bu on the rearing red horse Red Hare parrying with his crescent halberd, Guan Yu with the green-dragon crescent blade, Zhang Fei thrusting the serpent spear, Liu Bei with twin swords, sparks flying where the blades meet; in the foreground the onlookers frozen in awe — the hero sitting in the dust, Sun Ce gaping with his spear trembling, Zhou Yu's ledger fallen at his feet, Sun Jian with his arm in a sling narrowing his eyes, and the woman general Dong Bai (adult) tied across a horse staring wide-eyed",
    "c2_setout": "setting off north on a country road: Sun Ce on a brown horse galloping ahead the wrong way; the short-haired hero and Zhou Yu on horseback exchanging a look and a smile; a covered carriage behind them",
    "c2_zumao_saved": "a battlefield: the hero hurling a huge broad saber that strikes the giant Hua Xiong on the back of his helmet; the veteran Zu Mao in a red headscarf falling from his horse, saved",
    "c2_counter": "Sun Jian's camp: the burly Sun Jian hugging Lady Wu while glaring at the hero over her shoulder; the hero grinning awkwardly",
    "c2_keep": "inside a carved carriage: Lady Wu gently combing the hair of the captured woman general Dong Bai, who sits stiff-necked with reddened eyes, the hero peeking in at the curtain",
    "c2_handover": "a restrained, somber scene: the woman general Dong Bai in a prisoner cart looking back over her shoulder, the hero standing alone at the camp gate, grey sky (no gore)",
    "c2_triple": "a lavish allied lords' banquet: warlords crowding around the hero with wine cups, Yuan Shao giving up his seat, Sun Jian clapping the hero on the shoulder, Lady Wu watching from the side",
    "c2_dongbai_join": "a burning Luoyang street at night: the woman general Dong Bai striding toward the hero with her two giant bronze hammers, a line of Xiliang female cavalry guards kneeling behind her, ruined houses and refugees",
    "e_tangji": "a ruined temple: Lady Tang, an adult woman in coarse clothes with soot on her cheek, clutching a jade hairpin, looking up with unyielding eyes as the hero and Lady Wu find her",
    "e_yazhai": "a mountain bandit fort: the curvy bandit queen 'Rouge Tiger' standing hands on hips on the fort wall with twin sabers, pointing at the embarrassed hero, her chubby husband carrying a pig behind her (comedic)",
    "e_shengnv": "a forest clearing: the Yellow Turban saint Zhang Ning, an adult woman in a yellow Taoist robe with a nine-section staff, handing out bowls of charm water to kneeling ragged followers",
    "c2_yuxi": "burning Luoyang at night: Sun Jian by a well holding up the glowing Imperial Jade Seal, his face lit by five-colored light, his eyes turning ambitious",
    "i1_sewing": "night by lamplight: Lady Wu sewing a winter coat, the young man sitting beside her, Sun Ce sulking outside the window",
    "i2_yuxi": "night on a river boat: Sun Jian hugging a brocade box at the bow, Lady Wu standing at the cabin door holding a late-night snack",
    "i2_duel": "sunset riverbank: Dong Bai and Sun Ce collapsed on the ground laughing after a long duel, hammers and spear dropped beside them",
    "i2_qin": "night on the stern of a boat: Lady Tang playing a guqin, Lady Wu draping a coat over her shoulders",
}


# hand-written prompts that replace the template for a key (e.g. the owner's own prompt for a scene).
# They are also kept after the art exists, in the archive section, so a redraw starts from the same prompt.
# chapter map backgrounds (quest id -> what the scroll shows, left to right); the game scrolls it sideways under the squares
MAPS = {
    "yuxi": "the road from burning Luoyang south to Luyang (in Nanyang commandery), left to right: the smoking ruins of Luoyang and a long line of refugees; hills and a starving army camp; the walled town of Luyang with a tavern street; rain-soaked farmland with a Yuan army camp; a narrow mountain pass in heavy rain at the far right",
    "shouluoyang": "ruined Luoyang being rebuilt, left to right: a campfire among the ashes; a road where officials' families were escorted west; a Xiliang grain convoy on a mountain foot road; the restored ancestral temple and city walls with Sun banners; a peaceful market street; at the far right the western road toward Chang'an",
    "changan": "Chang'an in winter, left to right: the grand city gate; Dong Zhuo's lavish mansion with a courtyard duel ring; the palace with a rockery garden; a scholar's modest house; the Minister's mansion; a lotus pond with the Phoenix Pavilion; at the far right the chancellor's mansion hung with red wedding lanterns",
    "jingxiang": "from Nanyang south to the Han river, left to right: the walled city of Wancheng in autumn with a courtyard kitchen; the reed-lined Yu river and its battlefield; the road south through hills; the walled city of Xiangyang on the Han river with a river fortress full of war boats; at the far right a lone pavilion on a rock above the river at Wanshan",
    "dongui": "one long campaign, left to right: snowy Chang'an palace and the Xuanping Gate; the Wei river road east; the mountains and Hangu Pass; half-restored Luoyang with Sun banners; the summer road south; a Yuan army camp; the walled city of Wancheng in Nanyang at the far right",
    "taodong": "the march north to fight Dong Zhuo, left to right: country roads and farmland leaving the south; a dusty Central-Plains "
               "highway with a burnt village; the battlefield before Sishui Pass where Hua Xiong fought (a mountain gap with a watchtower); "
               "Sun Jian's big army camp with palisades, tents and red banners; a barren windswept wasteland (Hulao Pass, where the three "
               "heroes fought Lü Bu); and at the far right the walls of Luoyang burning at dusk, smoke rising into an ember sky",
}

# relic icons (cards.json relics id -> the object itself)
# Authentic ancient Chinese items, pure cut-outs on transparent backgrounds (no western circular medallion).
# Excluded lord/protagonist relics per user instruction: jiujia, hupi, qixing, zhaoxianbang, yitian, yuxi.
RELICS = {
    "shoushihe": "an exquisite Han dynasty Chinese lacquer jewelry box (汉代黑红髹漆妆奁), lid slightly ajar showing delicate jade hairpins, gold tassels and pearls inside",
    "jiunang": "an ancient Chinese gourd flask wine pouch (左慈酒葫芦/酒囊), polished leather and dried gourd with brass spout, wrapped in ceremonial red cord with a bronze coin charm",
    "bingfu": "an authentic ancient Chinese Han dynasty bronze Tiger Tally (汉代错金铜虎符), cast in the shape of a crouching tiger with inlaid gold seal script characters on its back",
    "hushenfu": "a traditional Chinese silk protective amulet pouch (汉代朱砂平安符囊), triangular folded cinnabar red silk embroidered with gold cloud patterns, bound by silk cord with a jade bead and red tassels",
    "xiangnang": "an authentic Han dynasty Chinese embroidered scented sachet (汉代刺绣茱萸香囊), rhombus-shaped silk pouch with gold thread floral embroidery, tied with a traditional Chinese mystic knot (同心结) and dual crimson silk tassels",
    "jinfan": "Gan Ning's Brocade Sail Bells (甘宁锦帆铃), two ornate ancient Chinese bronze ringing bells with incised wave patterns, bound together with a vibrant flowing patterned brocade silk ribbon",
    "bingfa": "an ancient Chinese bamboo scroll book of Sun Tzu's Art of War (孙子兵法竹简), aged brown bamboo slips bound with leather cord, partially unrolled to reveal brush-inked clerical script calligraphy, paired with a small bamboo calligraphy brush",
    "gudingdao": "Sun Jian's ancient broad-bladed saber with a ring pommel (古锭刀), an authentic Han dynasty ring-pommel broad saber (环首刀) with brass cloud-pattern fittings and a black-lacquered wood scabbard with red tassels",
    "yushan": "Zhou Yu's crane feather fan (周瑜白鹤羽扇), pure white crane feathers neatly arranged, bound with a carved pale green jade handle and silk tassel",
    "zhangu": "a Han dynasty Chinese red-lacquered war drum (汉军战鼓), heavy cowhide drumhead, ornate dragon brass studs on the drum rim, resting beside a pair of wooden drumsticks wrapped in red cloth",
    "chize": "Sun Jian's red headscarf (祖茂/孙坚赤帻), a bold crimson silk warrior turban cloth with battle wear and scorched edges, tied with a knot",
    "qinggang": "the legendary Qinggang Sword (青釭剑), a pristine double-edged Chinese straight sword (汉剑) of tempered blue-tinted steel, intricate brass guard with dragon engravings and dark lacquered scabbard",
    "bazhen": "Zhuge Liang's Eight Trigrams Formation scroll (八阵图), an antique silk map scroll spread open showing painted bagua diagrams, stones, and tactical compass markings in vermilion and ink",
    "dunjia": "Zuo Ci's Book of Dunjia (遁甲天书), an ancient mystical Taoist silk-bound tome with archaic seals, faint golden light, and paper talismans tucked between the aged pages",
    "muniu": "the Wooden Ox (木牛流马), an ingenious ancient Chinese mechanical wooden transport in the stylized shape of a carved wooden ox with bronze gears and levers",
    "beishui": "an ancient bronze three-legged cooking cauldron (破釜) with chipped rim and battle scratches, beside a charred burning ship plank",
    "dingxin": "an ancient Chinese medicinal pill box (定心丸), carved dark cinnabar lacquer box containing a gleaming golden herb-rolled pill on yellow silk lining",
    "jubaopen": "the Treasure Basin (聚宝盆), an ornate Han dynasty bronze and gilt basin filled with sparkling sycee silver ingots (元宝), gold nuggets, and antique coins",
    "chitu": "Red Hare's ceremonial golden saddle and bridle (赤兔金鞍缰辔), an opulent warhorse saddle of crimson leather and gilded bronze fittings, with ornate brass stirrups and red plume bridle",
    "zhangba": "the blade head of Zhang Fei's Eighteen-foot Snake Spear (丈八蛇矛), undulating wavy steel spear blade shaped like a writhing serpent, with a black steel socket and crimson horsehair tassel",
    "zhugenu": "Zhuge's Repeating Crossbow (诸葛连弩), an ingenious Han dynasty wooden multi-shot crossbow with top-mounted bolt magazine and bronze firing mechanism",
    "qinglong": "the head of Guan Yu's Green Dragon Crescent Blade (青龙偃月刀), heavy steel curved glaive blade with an engraved green dragon swallowing the steel base, adorned with a brass dragon collar and crimson tassel",
    "mengde": "Cao Cao's New Book of Mengde (孟德新书), a fine silk-wrapped bamboo scroll case and unrolled bamboo slips bearing Cao Cao's military commentary and vermilion personal seal",
    "heishan": "the Black Mountain Command Token (黑山令), an imposing dark iron and bronze pass token engraved with a fierce coiled dragon and archaic Chinese characters, tied with rough braided rope",
    "taipingyaoshu": "Zhang Jue's Essential Art of Great Peace (太平要术), ancient scrolls bound in yellow silk, covered with vermilion Taoist incantations, thunder talismans, and celestial diagrams",
    "qingnang": "Hua Tuo's Green Pouch Book (青囊书), a weathered green brocade medicine scroll bundle tied with leather cords, accompanied by silver acupuncture needles and dried healing herbs",
    "huangjinfu": "a Yellow Turban Talisman (黄巾符), yellow hemp paper talisman inscribed with cinnabar red mystical Daoist spell script, singed by lightning and smoke at the corners",
    "dilu": "Hex Mark's silver stirrup and bridle (的卢辔饰), refined white leather and silver-inlaid bridle and bit with tear-shaped silver ornaments and blue tassels",
    "fangtian": "the head of Lü Bu's Sky Piercer Halberd (方天画戟), a formidable four-pointed spearhead flanked by dual polished crescent moon side blades and red battle tassels",
    "tengjia": "the Southern Rattan Armor (藤甲), woven impenetrable dried wild mountain vine breastplate, treated with oil and bound with brass rivets",
}


# ？ event illustrations (event id -> scene); shown full-screen when the event comes up, like a story CG (key e_<id>)
EVENTS = {
    "biwu": "a red-silk fighting stage at a village entrance with a sign 比武招亲, a cheerful adult woman in pale-green armor spinning a spear on it, defeated suitors in a row, Sun Ce rolling up his sleeves while Zhou Yu grabs his collar",
    "ambush": "river bandits bursting out of tall reeds with gongs and rusty sabers, shouting",
    "snake": "comic scene: the short-haired hero hopping on one leg clutching his thigh, a small green bamboo viper slithering away, Sun Ce and Zhou Yu doubled over laughing",
    "tiger": "a white-browed tiger lounging on a rock on a mountain road, lazily licking its paw, staring at the viewer",
    "zuoci": "a white-haired old Taoist grinning with two front teeth, sitting on a boulder with a bamboo staff, purple smoke curling from a gourd in his hand",
    "chest": "a rusty iron chest half-buried by the roadside, carved with four small characters 非礼勿开",
    "hero": "a burly man in a roadside tavern smashing a table with one fist, wine cups flying, drinkers scattering",
    "refugees": "a column of ragged refugees on a dusty road, an old man collapsed, a mother holding a child out toward the viewer",
    "washer": "a cheerful adult woman washing clothes at a mountain stream, sleeves rolled up, laughing, a basket of cloth beside her",
    "dice": "river bandits gambling with dice on a broken boat by the river, waving the viewer over",
    "fruit": "a tree heavy with glossy red fruit by an empty road, Zhou Yu raising a warning finger",
    "risk": "a small boat in thick river fog, an old boatman squatting at the bow smoking a long pipe, dangerous rapids ahead",
    "temple": "a crumbling mountain temple with a noseless earth-god statue, half a stick of incense still smoking in the censer",
    "grand_chest": "a big gilded chest carved with the character 袁 in an army camp, a pompous lord forcing a smile",
    "huatuo": "a lean middle-aged doctor treating a village woman at a roadside medicine stall, his box painted 沛国华佗",
    "yuji": "a Taoist in white blocking the road, waving a banner reading 于吉仙师 符水治百病, followers kneeling",
    "merchant": "a plump merchant with a donkey cart piled with exotic goods, spreading his arms in welcome",
    "smith": "a roadside smithy with a roaring forge, a bare-chested old blacksmith hammering a glowing blade",
    "tomb": "a half-collapsed ancient tomb in a mountain hollow, cold wind from the entrance, Sun Ce stepping in eagerly while Zhou Yu checks his ledger",
    "guanlu": "a young diviner at a fortune-telling stall under a tree, sign reading 管辂神算",
    "xushao": "the famous critic Xu Shao holding court under a tree by the roadside, a crowd of hopeful men waiting for his one-line verdicts",
    "qiao": "two beautiful adult sisters washing clothes by a river, one gentle and one lively, Sun Ce and Zhou Yu frozen mid-step staring",
    "drink": "a tavern drinking contest: Sun Ce slamming a wine jar on the table, a crowd of drinkers circling and cheering",
    "deserters": "ragged deserters without armour crouching by the road gnawing bark, shrinking back in fear",
    "storm": "a sudden thunderstorm turning a road into mud, the army struggling through the rain",
    "horse": "a horse dealer holding the reins of two horses — a white-faced one with an ominous look and a fiery red one",
    "convoy": "a few Xiliang soldiers escorting grain carts with sacks stamped 董 along a road below a hill",
    "surrender": "a small group of men in yellow headscarves carrying a white flag, kneeling on a road",
    "shanzei": "a one-eyed bandit with a big axe jumping out at a mountain bend, his gang behind him",
    "shanzhai": "a mountain bandit fort with a tattered 替天行道 banner, smoke of roasting meat rising, Sun Ce swallowing",
    "jieying": "a night camp raid: dogs barking, a wall of torches coming out of the dark",
    "hj_camp": "a Yellow Turban remnant camp in a valley: old people, children and women around a pot of wild greens, thin smoke",
    "hj_medics": "a ruined temple where a woman in a yellow headscarf cleans a wounded soldier's wound, a Taiping talisman on her medicine box",
    "hj_road": "Yellow Turban remnants charging out of a forest with sticks and bamboo spears, shouting",
    "yuan_tax": "a roadside toll shed where two soldiers in Yuan livery block the road with spears, demanding rice",
    "black_market": "a narrow alley at night lit by a green lantern, a masked man opening his coat full of stolen treasures",
    "jz_spy": "a suspicious peddler caught at a city gate, a map of the city defences falling out of his carrying pole",
    "veterans": "two old soldiers, one missing an arm, sunning themselves at a city gate and recognising Sun Ce with joy",
    "plague": "a village entrance hung with white cloth, an old doctor raising his hand to stop the viewer",
    "yuxi_rumor": "a crowded teahouse, everyone whispering behind their hands",
    "tongyao": "children clapping and running along a road singing, in the background the silhouette of a huge fat man",
    "zhuhou_yan": "an envoy presenting an invitation card from the allied commander's camp, banquet tents in the background",
}
# 天命 pictures (cards.json fates id -> symbol); godot/data/art/fates/<id>.png, shown on the 天命 pick
FATES = {
    "jiangxing": "a brilliant general's star blazing above a Han helmet on a battlefield at night",
    "tiebi": "an iron wall of interlocking Han shields, arrows bouncing off",
    "bingduo": "a sea of banners and spears stretching to the horizon",
    "shenji": "a tactician's hand placing a black go stone on a battle map, glowing lines spreading",
    "tianshi": "a sundial and a bronze water clock under a turning sky",
    "renzhe": "a pair of hands offering a bowl of rice and a bandage to a wounded soldier",
    "caiyun": "a bronze coin tree heavy with golden coins and ingots",
    "xiansheng": "a war drum struck with a shockwave of sound, war cries",
    "jixing": "a lucky star and five-coloured auspicious clouds",
    "beishui": "broken cauldrons and a burning boat at a riverbank, soldiers facing the enemy with no way back",
    "luanshi": "a blood-red sky over burning cities, fortune favouring the bold",
    "jijin": "cavalry charging forward at full gallop in a blur of speed",
}
# 词缀 badges (cards.json battle.affixes id -> symbol); godot/data/art/affixes/<id>.png, shown in the battle info
AFFIXES = {
    "jianjia": "a heavy armour plate",
    "fayu": "a Taoist ward talisman glowing blue",
    "kuangbao": "a roaring red beast face",
    "houxue": "a thick red heart-shaped shield",
    "zaisheng": "a sprouting green herb",
    "xunjie": "a winged boot / swift wind swirl",
}
# full-screen UI pictures: godot/data/art/ui/<key>.jpg
UI_ART = {
    "title": "the title screen: a wide panoramic scene of the Three Kingdoms era at dawn — the Yangtze river in the foreground with a small boat, the young short-haired hero in silver armor with a cape standing on the bank looking north toward distant burning cities and banners; the sky split between warm sunrise and war smoke; leave the centre third of the frame calm and darker (the menu sits there)",
}


# the next batch for whoever draws (Gemini): in order; delivered ones drop off automatically
# Order follows pics/ART-PLAN.md §5 (P0 portraits first).
NEXT = [
    # P0 · 第三章·长安、第四章露脸的立绘（对话头像全程可见）：
    ("portrait", "dongzhuo", "董卓（第三章·长安首领）"),
    ("portrait", "wangyun", "王允"),
    ("portrait", "caiyong", "蔡邕"),
    ("portrait", "xiandi", "汉献帝（十岁左右的孩子，只画孩子该有的样子）"),
    ("portrait", "huangfusong", "皇甫嵩"),
    ("portrait", "lvlingqi", "吕玲绮（吕布之女，成年女性）"),
    ("portrait", "gaoshun", "高顺"),
    ("portrait", "xunyou", "荀攸"),
    ("portrait", "zhongyao", "钟繇"),
    ("portrait", "xuhuang", "徐晃（换掉占位）"),
    ("portrait", "huangzhong", "黄忠（换掉占位，四十出头的军汉，不是老将）"),

    # 第二章、第三章还没画完的：
    ("battle", "xiliang_youqi", "西凉游骑（尘土飞扬的中原官道）"),
    ("battle", "guosi", "郭汜（掠夺焚烧村落的西凉军寨）"),
    ("battle", "liru", "李儒伏兵（峡谷险道两侧峭壁伏兵）"),
    ("battle", "lijue", "洛阳城门·李傕（烈火焚城的洛阳门前，黑烟火星）"),
    ("battle", "xiliang_scout", "截粮·西凉斥候（山脚运粮辎重车队）"),
    ("cg", "c2_setout", "第二章开场：策马北上讨董（孙策跑偏、主角周瑜对视莞尔、吴夫人马车）"),
    ("cg", "e_tangji", "破庙救唐姬"),
    ("cg", "e_yazhai", "压寨夫人（胭脂虎指着主角）"),
    ("cg", "e_shengnv", "黄巾圣女（张宁施符水）"),
    ("portrait", "caiwenji", "蔡文姬"),
    ("portrait", "fengfuren", "冯夫人（袁术的宠姬，成年女性）"),
    ("portrait", "yuanshu", "袁术"),
    ("portrait", "jiling", "纪灵"),
    ("portrait", "leibo", "雷薄"),
    ("portrait", "chenlan", "陈兰"),
    ("portrait", "qiaorui", "桥蕤"),
    ("battle", "c3_shanfei", "独眼匪首（第三章流民匪患）"),
    ("battle", "c3_qiaorui", "城外·桥蕤（第三章南阳城外便装伏兵）"),
    ("battle", "c3_jiling", "山口·纪灵（第三章大雨隘口决战）"),
    ("battle", "c3_leibo", "山道追兵·雷薄（第三章清晨山道追击）"),
    ("battle", "c3_chenlan", "夜袭·陈兰（第三章雨夜火把夜袭）"),
    ("battle", "c3_yuanshu", "袁术（第三章金顶马车与大军）"),
    ("cg", "c3_leave", "撤离洛阳（流民大队与孙家车队）"),
    ("cg", "c3_wenji", "救蔡文姬（泥泞道边拾断弦琴）"),
    ("cg", "c3_supply", "饥民与军粮"),
    ("cg", "c3_slip", "酒肆说漏嘴（孙策拍桌吹牛，周瑜捂嘴）"),
    ("cg", "c3_entrust", "托付玉玺（孙坚夜交锦盒于吴夫人）"),
    ("cg", "c3_warn", "劝阻孙坚"),
    ("cg", "c3_raid", "陈兰雨夜袭营"),
    ("cg", "c3_news", "纪灵败退与噩耗"),
    ("cg", "c3_end", "碎玺决战（吴夫人碎玉玺面袁术）"),

    # P1 · 地图底图：
    ("map", "changan", "第三章·长安地图底图"),
    ("map", "dongui", "第四章·挟天子地图底图"),
    ("map", "yuxi", "第三章·传国玉玺地图底图"),

    # P2 · 首领 / 精英战斗 CG 和结局卡：
    ("battle", "c5_dongzhuo", "未央宫前·董卓（首领）"),
    ("battle", "c4_lvbu", "雪中宣平门·吕布（结局二前的最后一战）"),
    ("battle", "c7_jiling", "宛城西门·纪灵（首领）"),
    ("battle", "c6_lijue", "函谷关·李傕（首领）"),
    ("battle", "c4_gaoshun", "蔡府后门·高顺（精英）"),
    ("battle", "c5_niufu", "比武·牛辅（精英）"),
    ("battle", "c5_hall", "喜堂·飞熊军（精英）"),
    ("battle", "dagu", "大谷·徐荣（精英）"),
    ("cg", "end_yusui", "结局卡·玉碎（象征画，不画人）"),
    ("cg", "end_tonggui", "结局卡·同归（象征画，不画人，不见血）"),

    # 第五章 · 荆襄风云：
    ("portrait", "liubiao", "刘表（荆州牧，坐谈客）"),
    ("portrait", "caimao", "蔡瑁（水军都督，骄横外戚）"),
    ("portrait", "kuaiyue", "蒯越（荆襄谋主）"),
    ("portrait", "huangzu", "黄祖（江夏太守）"),
    ("portrait", "caifuren", "蔡夫人（荆州，成年女性）"),
    ("portrait", "jingzhou_gong", "荆州弓手（兵卡）"),
    ("portrait", "jingzhou_shuijun", "荆州水军（兵卡）"),
    ("cg", "c8_shuige", "水阁·貂蝉代饮（结局三线的关键一幕）"),
    ("cg", "c8_grapes", "水阁·揽入怀中剥葡萄（破局线的关键一幕）"),
    ("cg", "c8_louchuan", "月下楼船·糖炒栗子"),
    ("cg", "c8_liuxian", "留仙裙·淯水边"),
    ("cg", "c8_caifuren", "蔡夫人认同宗、送明珠"),
    ("cg", "c8_jiayan", "宛城家宴"),
    ("cg", "c8_dress", "盛装（吴夫人给貂蝉梳头）"),
    ("cg", "c8_xiangxiao", "香消（克制）"),
    ("cg", "c8_henhai", "恨海·汉江冷雨（克制）"),
    ("cg", "end_henhai", "结局卡·恨海（象征画，不画人，不见血）"),
    ("battle", "jx_huangzu", "淯水·黄祖（首领）"),
    ("battle", "jx_caimao_a", "水阁·独眼蔡瑁（结局三线首领）"),
    ("battle", "jx_caimao_b", "水阁·蔡瑁（破局线首领）"),
    ("battle", "jx_shuijun", "水寨·荆州水军（精英）"),
    ("battle", "jx_bubing", "淯水北岸·荆州步卒"),
    ("battle", "jx_gongshou", "芦苇荡·荆州弓手"),
    ("battle", "jx_nushou", "水阁·蔡府连弩手"),
    ("map", "jingxiang", "第五章·荆襄风云地图底图"),

    # 兵卡：
    ("portrait", "jiangdong_gong", "江东弓手（第一章缺失兵卡）"),
    ("portrait", "liehu", "山中猎户（第一章缺失兵卡）"),
    ("portrait", "yuenv_gong", "越女弓手（第一章缺失兵卡）"),
    ("portrait", "chenwu", "陈武（R 弓兵）"),
    ("portrait", "shanyue_nu", "山越弩手"),
    ("portrait", "sunjing", "孙静"),
    ("portrait", "sunben", "孙贲"),
    ("portrait", "zhuzhi", "朱治"),
]
# the chest sprites the chest-opening animation uses (godot/data/art/ui/chest_<key>.png)
CHESTS = {
    "chest_normal": "a sturdy wooden treasure chest with bronze corner caps and a heavy bronze padlock, Han-dynasty style, closed",
    "chest_grand": "a grand red-lacquered treasure chest painted with gold clouds and dragons, inset with jade, a faint golden glow leaking from the seam, closed",
}
# already delivered but wrong somewhere: redraw (listed above the batch)
REDO = [
    ("inf_n", "官军刀兵：盾牌上的鹰和回纹边是古希腊重装步兵盾的样式——换成汉军的盾（长方形或圆盾，黑红漆面，饕餮 / 云纹或素面），其他不变"),
]
NEXT_RULES = [
    "每张图都用下面对应小节的**完整提示词**；图上长相/器物必须和设定对得上（见 `CARD-DESIGN.md` 第 7 节）。",
    "宝物：纯中式汉代古风器物，独立透明背景（纯白背景抠图，无圆盘边框，无西式奇幻符号），日系战术卡牌 RPG 赛璐珞道具插画风。",
    "女性角色一律画成成年人；董白不写年龄、不画成萝莉。",
    "卡牌立绘必须带背景：背景为符合人物身份与阵营的古风场景（军营、要塞、江岸、山林、宫室等，具自然景深与环境光影，不再使用纯白/摄影棚素底）。人物半身居中，面部在上方三分之一。",
    "文件名 = key：宝物放 `pics/source/relics/<key>.png`（同时复制到 `godot/data/art/relics/<key>.png`），立绘放 `pics/source/generals/`（兵卡放 `soldiers/`）。",
    "战斗 CG 放 `pics/source/battles/<key>.jpg`、在 `pics/art.json` 的 battles 登记；构图：敌人大、居中、在画面中上部，下方 30% 为干净地面。",
    "宝箱图：PNG 透明底 512×512，直接放 `godot/data/art/ui/<key>.png`（开宝箱动画会自动用上）。",
    "立绘在 `pics/art.json` 对应段登记；然后跑 `sanguo-art`，再跑 `python tools/art_prompts.py` 刷新本文件。",
    "**不要覆盖已经交付的图**；重画某张时旧图别留在 `pics/source/` 里（`backup_old/` 之类的文件夹不要提交）。",
    "提交时按路径 `git add`，只提交自己的图和登记，别带上别人没提交的改动。",
]


def map_prompt(scene: str) -> str:
    return (f"A wide horizontal game map illustration, a hand-painted Chinese landscape scroll (浅绛 / 青绿山水): {scene}.{NL}"
            f"Composition & Framing: very wide panorama, 3200x1080 (it scrolls sideways), seen from high above at an angle; keep three "
            f"roughly horizontal travel bands (top / middle / bottom) free of busy detail, map squares sit on them; soft mist.{NL}"
            f"Style: match the chapter-1 map (godot/data/art/map/prologue.jpg): ink outlines, soft green and ochre washes on rice paper; "
            f"no text, no UI, no people close up.")


def relic_prompt(obj: str, rarity: str) -> str:
    return (f"Masterpiece 1:1 square game inventory item icon of {obj}.{NL}"
            f"Composition & Framing: square 256x256 (draw at 1024x1024), the item is displayed cleanly as an isolated single artifact, angled dynamically in center.{NL}"
            f"Solid plain off-white background (#ffffff), clean cut-out, no border, no frame, no circular medallion, no runes, no western fantasy elements.{NL}"
            f"Style: Authentic ancient Chinese Three Kingdoms artifact aesthetic, retro Japanese anime RPG tactical game item illustration, Rance X art style inspiration, crisp clean ink outlines, rich vibrant cel-shading, delicate metallic highlights; no text.")


OVERRIDES = {
    "i1_sewing": """横版 16:9 剧情CG插画，三国日系战术卡牌RPG第一章通关幕间事件图：【吴夫人的针线 · 窗里温存与窗外受气包】
- 室内温馨核心互动（暖光主舞台）：
  - 深夜的富春庄园寝房内，案几上的油灯洒下暖洋洋的橘色柔光。
  - 【吴夫人（宠溺调侃）】：三十多岁的绝色美妇身穿素雅柔顺的居家对襟襦裙，青丝微挽。膝头放着一件正缝制到一半的厚实保暖冬衣，手中捏着细长的缝衣针，正笑靥如花、极其宠溺地拿圆润的针尾轻轻敲了一下主角的额头，眼神满是亲昵与调侃。
  - 【主角（心满意足）】：青年主角坐在她身旁，微笑着伸手让夫人比量衣袖长短，桌边搁着他刚端进来的一大碗热气腾腾的枸杞鸡汤与竹编针线笸箩。
- 窗外喜剧反差神笔（画龙点睛的笑点）：
  - 透过室内敞开的雕花木窗，映出窗外清冷的青蓝月夜庭院：
  - 【可怜的孙策】：少年孙策正像个被遗弃的小狗一样，孤零零蹲在墙根底下的泥地里。手里死死抓着自己那件线头乱飞、歪歪扭扭还没缝好的烂棉袄，鼓着圆滚滚的包子脸，眼泪汪汪又咬牙切齿地透过窗户缝偷看屋里亲昵的两人，委屈酸楚溢出屏幕！
- 构图光影与画风：
  - 极富戏剧魅力的双重冷暖光影：屋内是充满熏香、热汤与针线温情的金黄暖光，屋外是照着委屈孙策的清冷月光。
  - 规格：横版 16:9 比例，日系经典战术卡牌RPG剧情CG插画风（赛璐珞上色带精良墨线，类似兰斯10经典幕间短剧插画），人物神态极其生动鲜活，温馨甜蜜中带着无厘头爆笑！""",
}

def portrait_prompt(p: tuple) -> str:
    if len(p) >= 5:
        name, look, clothes, weapon, bg = p[:5]
    else:
        name, look, clothes, weapon = p
        bg = "an atmospheric ancient Chinese scene matching the character, soft natural lighting"
    return (f"A vertical character portrait of {name}.{NL}"
            f"Appearance: {look}{NL}"
            f"Armor & Clothing: {clothes}{NL}"
            f"Weapon: {weapon}{NL}"
            f"Background: {bg}.{NL}"
            f"Composition & Framing: {PORTRAIT_COMPOSITION}{NL}"
            f"Style: {STYLE}, atmospheric environmental lighting, soft depth of field keeping the background scenic yet secondary to the character.")


def battle_prompt(scene: str) -> str:
    return (f"A horizontal battle scene illustration: {scene}.{NL}"
            f"Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, dramatic low angle; the enemy big and centred in the "
            f"upper-middle of the frame (its head / face about 30-45% from the top), the bottom 30% simple ground.{NL}"
            f"Style: {STYLE}, dramatic battle lighting, like a Rance X battle CG; no text, no UI.")


def cg_prompt(scene: str) -> str:
    return (f"A horizontal story event illustration: {scene}.{NL}"
            f"Composition & Framing: Horizontal 16:9 aspect ratio, 1920x1080, characters in the upper two thirds, the bottom third "
            f"less busy (dialogue text sits there). At most four named characters in focus; unnamed background people "
            f"(soldiers, crowds) are fine.{NL}"
            f"Style: {STYLE}, visual-novel event CG, expressive faces, warm cinematic lighting; no text, no UI.{NL}"
            f"(When the hero appears — {HERO}.)" + (f"{NL}({DONGBAI}.)" if "Dong Bai" in scene else ""))


def fate_prompt(sym: str) -> str:
    return (f"A square emblem illustration for a 'fate' card in a roguelike: {sym}.{NL}"
            f"Composition & Framing: square 512x512 (draw at 1024x1024), the symbol centred inside a round jade-and-gold medallion "
            f"with a thin gold rim, transparent background (PNG).{NL}"
            f"Style: {STYLE}, painted emblem, strong silhouette readable at 112px; no text.")


def affix_prompt(sym: str) -> str:
    return (f"A tiny game badge icon: {sym}, drawn as a red Chinese seal stamp (朱印) with the symbol carved inside.{NL}"
            f"Composition & Framing: square 128x128 (draw at 512x512), transparent background (PNG), bold simple shapes readable at 28px.{NL}"
            f"Style: ink and cinnabar, crisp edges; no text.")


def ui_prompt(scene: str) -> str:
    return (f"A horizontal key-art illustration for {scene}.{NL}"
            f"Composition & Framing: Horizontal 16:9, 1920x1080; the picture is shown dimmed under the menu.{NL}"
            f"Style: {STYLE}, epic cinematic lighting, painterly sky; no text, no logo, no UI.{NL}"
            f"(The hero — {HERO}.)")


def main() -> None:
    art = json.loads((PICS / "art.json").read_text("utf-8"))
    done = {k for k, v in art["portraits"].items() if not v.get("placeholder")}
    out = ["# 出图提示词", "",
           "> 由 `python tools/art_prompts.py` 生成：每一条都能直接复制去出图。已有正式美术的会自动跳过。",
           "> 新角色 / 新战斗 / 新剧情插图：先在 `tools/art_prompts.py` 的表里加一行，再运行它。",
           "> 出好的图按 key 命名：立绘放 `pics/source/generals/`（兵卡放 `soldiers/`），战斗 CG 放 `pics/source/battles/`，",
           "> 剧情 CG 放 `pics/source/cg/`；然后在 `pics/art.json` 登记、运行 `sanguo-art`（见 `CARD-DESIGN.md`）。", "",
           ]
    maps_done = {k for k, v in art.get("maps", {}).items() if "生成" not in v.get("license", "")}
    relics_done = {p.stem for p in (ROOT / "godot" / "data" / "art" / "relics").glob("*.png")}
    ui_done = {k for k in CHESTS if (ROOT / "godot" / "data" / "art" / "ui" / f"{k}.png").exists()}
    delivered = {"portrait": done, "cg": set(art.get("cgs", {})), "map": maps_done, "relic": relics_done,
                 "battle": set(art.get("battles", {})), "ui": ui_done}
    todo = [n for n in NEXT if n[1] not in delivered[n[0]]]
    if todo:
        out += ["## 下一批（交给 Gemini）", "", "按顺序画；交付后重跑本脚本，这一条会自动消失。", ""]
        if REDO:
            out += ["**先重画**（已交付但有地方不对）：", ""] + [f"- `{k}` — {why}" for k, why in REDO] + [""]
        out += [f"{i}. `{key}` — {what}（{ {'portrait': '立绘', 'cg': '剧情 CG', 'map': '地图', 'relic': '宝物', 'battle': '战斗 CG', 'ui': '界面'}[kind] }）"
                for i, (kind, key, what) in enumerate(todo, 1)]
        out += ["", "交图规则：", ""] + [f"- {r}" for r in NEXT_RULES] + [""]
    out += ["## 立绘（竖版 3:4）", ""]
    redo = {k for k, _ in REDO}
    for key, p in PORTRAITS.items():
        if key in done and key not in redo:
            continue
        status = "🟡 换掉占位" if key in art["portraits"] else "⬜ 缺"
        out += [f"### `{key}` {status}", "", "```", OVERRIDES.get(key) or portrait_prompt(p), "```", ""]
    out += ["## 战斗 CG（横版 16:9，每场战斗一张）", ""]
    for key, scene in BATTLES.items():
        if key in art.get("battles", {}):
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or battle_prompt(scene), "```", ""]
    out += ["## 剧情插图 CG（横版 16:9）", ""]
    for key, scene in CGS.items():
        if key in art.get("cgs", {}) and key not in redo:
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or cg_prompt(scene), "```", ""]
    out += ["## 奇遇插图（？格事件，横版 16:9，key = e_<事件 id>，放 `pics/source/cg/`，和剧情 CG 一样登记）", ""]
    for eid, scene in EVENTS.items():
        key = "e_" + eid
        if key in art.get("cgs", {}):
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or cg_prompt(scene), "```", ""]
    art_dir = ROOT / "godot" / "data" / "art"
    out += ["## 天命图（512×512 透明 PNG，放 `godot/data/art/fates/<key>.png`；没有图时显示一个汉字）", ""]
    for key, sym in FATES.items():
        if (art_dir / "fates" / f"{key}.png").exists():
            continue
        out += [f"### `{key}`", "", "```", fate_prompt(sym), "```", ""]
    out += ["## 词缀徽记（128×128 透明 PNG，放 `godot/data/art/affixes/<key>.png`）", ""]
    for key, sym in AFFIXES.items():
        if (art_dir / "affixes" / f"{key}.png").exists():
            continue
        out += [f"### `{key}`", "", "```", affix_prompt(sym), "```", ""]
    out += ["## 界面大图（横版 16:9 JPG，放 `godot/data/art/ui/<key>.jpg`）", ""]
    for key, scene in UI_ART.items():
        if (art_dir / "ui" / f"{key}.jpg").exists():
            continue
        out += [f"### `{key}`", "", "```", ui_prompt(scene), "```", ""]
    out += ["## 宝箱图（开宝箱动画用，512×512 透明 PNG，放 `godot/data/art/ui/<key>.png`）", ""]
    for key, obj in CHESTS.items():
        out += [f"### `{key}`", "", "```", f"A game item sprite: {obj}.{NL}Composition & Framing: square 512x512, the chest centred "
                f"at a slight three-quarter angle, transparent background (PNG), no shadow box.{NL}Style: {STYLE}, painted prop, rich "
                f"colours, crisp outline; no text.", "```", ""]
    out += ["## 章节地图底图（横版宽图，放 `pics/source/map/bg_<key>.jpg`）", ""]
    for key, scene in MAPS.items():
        if "生成" not in art.get("maps", {}).get(key, {}).get("license", "生成"):
            continue
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or map_prompt(scene), "```", ""]
    rarity = {k: v.get("rarity", "common") for k, v in json.loads((ROOT / "godot/data/cards.json").read_text("utf-8"))["relics"].items()}
    out += ["## 宝物图标（256×256 透明 PNG，放 `pics/source/relics/<key>.png`；现在是程序生成的占位）", ""]
    for key, obj in RELICS.items():
        out += [f"### `{key}`", "", "```", OVERRIDES.get(key) or relic_prompt(obj, rarity.get(key, "common")), "```", ""]
    done_overrides = [k for k in OVERRIDES if k in art.get("cgs", {}) or k in art.get("battles", {}) or k in done]
    if done_overrides:
        out += ["## 已出图的提示词存档（重画时从这里开始）", ""]
        for key in done_overrides:
            out += [f"### `{key}` ✅", "", "```", OVERRIDES[key], "```", ""]
    (PICS / "ART-PROMPTS.md").write_text(NL.join(out), "utf-8", newline=NL)
    print(f"wrote {PICS / 'ART-PROMPTS.md'}")


if __name__ == "__main__":
    main()
