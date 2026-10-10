"""Generate all custom character voicelines with distinct timbres:
1. 主角 (现代男青年穿越者): 普攻「你妹！」「去你的！」，大招「砸不死你！」 (Yunxi)
2. 男武将 (英武刚猛名将): 普攻「看招！」「休想跑！」，大招「万军莫当！」「受死吧！」 (Yunjian)
3. 女武将 (英姿飒爽巾帼): 普攻「看招！」「休想跑！」，大招「给我瞧好了！」「巾帼岂让须眉！」 (Xiaoyi)
4. 军师 (深邃从容谋士): 出招「破绽已现！」「尽在掌握！」，大招「计定乾坤！」 (Yunyang)
5. 治疗 (柔美温婉女性): 治愈「为你疗伤……」「别怕，安心休养……」「伤口……好些了吗？」 (Xiaoxiao)

All audio is standardized to 16-bit 44100Hz mono PCM WAV and trimmed to exact 0.0ms onset.
"""
import asyncio
import io
import os
import subprocess
import wave
from pathlib import Path
import numpy as np
import edge_tts
import imageio_ffmpeg

FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
ROOT = Path(__file__).resolve().parents[1]
SFX_DIR = ROOT / "godot/data/audio/sfx"


def normalize_and_trim(pcm: np.ndarray, sr: int = 44100, thresh_ratio: float = 0.05, target_peak: int = 29500) -> np.ndarray:
    peak = np.max(np.abs(pcm))
    if peak == 0:
        return pcm
    thresh = peak * thresh_ratio
    idx = np.where(np.abs(pcm) >= thresh)[0]
    if len(idx) == 0:
        return pcm
    start = max(0, idx[0] - int(sr * 0.001))
    end = min(len(pcm), idx[-1] + int(sr * 0.12))  # 保留自然衰减尾音，切除空白
    trimmed = pcm[start:end].copy()

    # 统一峰值标准化到 target_peak (约 -0.8 dBFS)，确保主角与各角色声像贴耳饱满、解决“声音偏远”问题
    curr_peak = np.max(np.abs(trimmed))
    if curr_peak > 0:
        scale = target_peak / float(curr_peak)
        trimmed = np.clip(trimmed * scale, -32767, 32767).astype(np.int16)

    fade_len = int(sr * 0.002)
    if len(trimmed) > fade_len:
        trimmed[:fade_len] = (trimmed[:fade_len] * np.linspace(0, 1, fade_len)).astype(np.int16)
        trimmed[-fade_len:] = (trimmed[-fade_len:] * np.linspace(1, 0, fade_len)).astype(np.int16)
    return trimmed


def convert_and_save(mp3_bytes: bytes, out_path: Path):
    # 统一纯净高保真通道：所有角色（我方与敌方）在同一声学轨道下，杜绝人造畸变
    cmd = [FFMPEG, "-y", "-i", "pipe:0", "-f", "s16le", "-ac", "1", "-ar", "44100", "pipe:1"]
    out = subprocess.run(cmd, input=mp3_bytes, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout
    pcm = np.frombuffer(out, dtype=np.int16)
    trimmed = normalize_and_trim(pcm, sr=44100)
    with wave.open(str(out_path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(44100)
        w.writeframes(trimmed.tobytes())
    print(f"Generated: {out_path.name} ({len(trimmed)/44100*1000:.1f}ms, {out_path.stat().st_size} bytes)")


async def synth_line(text: str, voice: str, rate: str, pitch: str, out_name: str):
    communicate = edge_tts.Communicate(text, voice, rate=rate, pitch=pitch)
    data = bytearray()
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            data.extend(chunk["data"])
    convert_and_save(bytes(data), SFX_DIR / out_name)


async def main():
    print("=== Generating Character Lines with Distinct Timbres (Unified Track) ===")
    tasks = [
        # 1. 主角 (现代男青年穿越者 - Yunxi)
        synth_line("你妹！", "zh-CN-YunxiNeural", "+15%", "+6Hz", "shout_hero_1.wav"),
        synth_line("去你的！", "zh-CN-YunxiNeural", "+15%", "+6Hz", "shout_hero_2.wav"),
        synth_line("砸不死你！", "zh-CN-YunxiNeural", "+12%", "+5Hz", "shout_hero_ult.wav"),

        # 2. 男武将 (英武刚烈名将 - Yunjian)
        synth_line("看招！", "zh-CN-YunjianNeural", "+10%", "-2Hz", "shout_male_1.wav"),
        synth_line("休想跑！", "zh-CN-YunjianNeural", "+10%", "-2Hz", "shout_male_2.wav"),
        synth_line("万军莫当！", "zh-CN-YunjianNeural", "+6%", "-3Hz", "shout_male_ult.wav"),
        synth_line("受死吧！", "zh-CN-YunjianNeural", "+8%", "-2Hz", "shout_male_3.wav"),

        # 3. 女武将 (清脆英气巾帼 - Xiaoyi)
        synth_line("看招！", "zh-CN-XiaoyiNeural", "+10%", "+2Hz", "shout_female_1.wav"),
        synth_line("休想跑！", "zh-CN-XiaoyiNeural", "+10%", "+2Hz", "shout_female_2.wav"),
        synth_line("看我破阵！", "zh-CN-XiaoyiNeural", "+6%", "+2Hz", "shout_female_ult.wav"),
        synth_line("给我瞧好了！", "zh-CN-XiaoyiNeural", "+8%", "+1Hz", "shout_female_3.wav"),

        # 4. 军师 (深邃儒雅谋士 - Yunyang)
        synth_line("破绽已现！", "zh-CN-YunyangNeural", "+6%", "-3Hz", "shout_strat_1.wav"),
        synth_line("尽在掌握！", "zh-CN-YunyangNeural", "+6%", "-3Hz", "shout_strat_2.wav"),
        synth_line("计定乾坤！", "zh-CN-YunyangNeural", "+4%", "-4Hz", "shout_strat_ult.wav"),

        # 5. 治疗 (温婉柔美仙子/医仙 - Xiaoxiao)
        synth_line("为你疗伤……", "zh-CN-XiaoxiaoNeural", "-6%", "+2Hz", "voice_heal_female_1.wav"),
        synth_line("别怕，安心休养……", "zh-CN-XiaoxiaoNeural", "-6%", "+2Hz", "voice_heal_female_2.wav"),
        synth_line("伤口……好些了吗？", "zh-CN-XiaoxiaoNeural", "-6%", "+2Hz", "voice_heal_female_3.wav"),

        # 6. 敌将/头目 (凶狠威严、大汉悍匪 - Yunjian，同音轨高保真输出)
        synth_line("拿命来吧！！", "zh-CN-YunjianNeural", "+10%", "-2Hz", "shout_enemy_1.wav"),
        synth_line("给我上！宰了他！", "zh-CN-YunjianNeural", "+10%", "-2Hz", "shout_enemy_2.wav"),
        synth_line("拿命来！受死吧！", "zh-CN-YunjianNeural", "+12%", "-2Hz", "shout_enemy_3.wav"),
        synth_line("都给我上！受死吧！", "zh-CN-YunjianNeural", "+8%", "-3Hz", "shout_enemy_roar.wav"),

        # 7. 女性敌将 (极少数女头目如董白/胭脂虎 - Xiaoyi)
        synth_line("拿命来！", "zh-CN-XiaoyiNeural", "+12%", "+2Hz", "shout_enemy_female_1.wav"),
        synth_line("给我上！", "zh-CN-XiaoyiNeural", "+12%", "+2Hz", "shout_enemy_female_2.wav"),
        synth_line("都给我上！", "zh-CN-XiaoyiNeural", "+10%", "+1Hz", "shout_enemy_female_roar.wav"),
    ]
    await asyncio.gather(*tasks)
    print("=== All Voice Lines Generated Successfully! ===")


if __name__ == "__main__":
    asyncio.run(main())
