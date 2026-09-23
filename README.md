# MINIMAX-H3 自研文戏低配版

MiniMax H3 **文戏（对话/剧情向）** 参考转视频工作流的低显存优化版，ComfyUI API 格式交付。

## 一、工作流能力

| 项目 | 说明 |
|---|---|
| 类型 | 图生视频（9 参考图 → 视频+音频） |
| 时长 | 15 秒（`529` 节点可调） |
| 分辨率 | 16:9 宽屏 · 0.5MP（`456` 节点可调） |
| 帧率 | 24 fps |
| 输出 | H.265 MP4（视频+音频双轨） |
| 采样 | 双路：粗采样 + H3SigmaRefiner 二阶精炼 |

## 二、低显存优化（本版核心）

- `MiniMaxLowVRAMAttention`（head_chunks=4）：低显存注意力
- `MiniMaxChunkFeedForward`（chunks=4, seq_threshold=3072）：分块前馈
- `MiniMaxH3MemoryEfficientSageAttentionPatch` ×2：SageAttention 内存优化
- `MinimaxH3LatentUpscaler3D`：潜空间三维上采样（1.5x），低清先出、潜空间抬升

## 三、模型依赖

以下模型文件需放入 ComfyUI 对应目录：

| 模型文件 | 放置目录 | 用途 |
|---|---|---|
| `minimax_h3_video_vae_fp16.safetensors` | `models/vae/` | 视频 VAE |
| `minimax_h3_audio_vae_fp32.safetensors` | `models/vae/` | 音频 VAE |
| `qwen3vl_32b_minimax_h3_int8_convrot.safetensors` | `models/text_encoders/` | 文本编码（CLIP） |
| `minimax_h3_hybrid_fl2va_ref2va_b25-49-int8.safetensors` | `models/checkpoints/` | 主干 UNet |
| `MysticXXX_MMH3-V1.safetensors` | `models/loras/` | 文戏风格 LoRA（强度 0.5） |
| `minimax_h3_turbo_v4_step600_ema_pruned_comfyui.safetensors` | `models/loras/` | Turbo 加速 LoRA（强度 1.0） |
| `minimax_h3_latent_upscaler_3d_fp16.safetensors` | `models/upscale_models/` | 潜空间上采样器 |

## 四、自定义节点依赖

- MiniMax H3 官方节点包（`MiniMaxH3ReferenceToVideo`、`H3SigmaRefiner`、`MiniMaxLowVRAMAttention` 等）
- `ComfyUI_VideoHelperSuite`（VHS_VideoCombine）
- `ComfyUI_LayerStyle`（LayerUtility: ImageScaleByAspectRatio V2）
- `Comfyroll Studio`（CR Prompt Text）
- ComfyMath（ComfyMathExpression）

## 五、快速启动

```bash
# 方式一：直接使用本仓库启动脚本
bash scripts/start_comfyui.sh

# 方式二：手动启动
cd /root/ComfyUI
python main.py --listen 0.0.0.0 --port 6006
```

## 六、API 调用（ComfyUI 原生 API）

```bash
# 1. 提交工作流（POST /prompt）
curl -X POST "http://<实例域名>:6006/prompt" \
  -H "Content-Type: application/json" \
  -d @workflows/minimax-h3-wenxi-low-end.json

# 返回 { "prompt_id": "..." }

# 2. 查询结果（GET /history）
curl "http://<实例域名>:6006/history/<prompt_id>"

# 3. 进度监控（WebSocket）
# ws://<实例域名>:6006/ws?clientId=...
```

## 七、工作流输入说明

- 提示词：`528` 节点（CR Prompt Text），文戏剧本 + 角色设定 + 分镜，支持 `<Subject1>`、`<Picture N>`、`<d>` 标签
- 参考图：`LoadImage` 节点（469/475/515/525/526/527/591/592/593），需先将图片上传至 ComfyUI `input/` 目录
- 时长：`529` 节点（Float, 默认 15）
- 分辨率：`456` 节点（ResolutionSelector, 默认 16:9 0.5MP）

## 八、目录结构

```
minimax-h3-wenxi-low-end/
├── README.md
├── workflows/
│   └── minimax-h3-wenxi-low-end.json   # API 格式工作流
└── scripts/
    └── start_comfyui.sh                 # 自动启动脚本
```
