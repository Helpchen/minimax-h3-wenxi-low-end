#!/bin/bash
# ============================================================
# MINIMAX-H3 自研文戏低配版 —— ComfyUI 自动启动脚本
# 适用于 AutoDL Art 镜像 / 云端实例，监听 0.0.0.0:6006
# 用法: bash scripts/start_comfyui.sh
# ============================================================
set -e

# --- 可配置项（按实际环境修改）---
COMFYUI_DIR="${COMFYUI_DIR:-/root/ComfyUI}"      # ComfyUI 安装目录
COMFYUI_PORT="${COMFYUI_PORT:-6006}"              # 服务端口
PYTHON_BIN="${PYTHON_BIN:-python}"                # Python 解释器
EXTRA_ARGS="${EXTRA_ARGS:-}"                      # 额外参数，如 --lowvram --force-fp16

# --- 目录校验 ---
if [ ! -d "$COMFYUI_DIR" ]; then
  echo "[ERROR] ComfyUI 目录不存在: $COMFYUI_DIR"
  exit 1
fi
cd "$COMFYUI_DIR"

# --- 环境激活（AutoDL 镜像常见写法，按需保留/注释）---
if [ -f /root/miniconda3/etc/profile.d/conda.sh ]; then
  # shellcheck disable=SC1091
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate comfyui 2>/dev/null || true
fi

# --- 模型/自定义节点完整性提示（不阻断启动）---
MODEL_DIR="${MODEL_DIR:-$COMFYUI_DIR/models}"
echo "[INFO] 模型目录: $MODEL_DIR"
echo "[INFO] 请确认以下模型文件已放入对应子目录（缺失会导致工作流报错）:"
echo "  - models/vae/          minimax_h3_video_vae_fp16.safetensors"
echo "  - models/vae/          minimax_h3_audio_vae_fp32.safetensors"
echo "  - models/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors"
echo "  - models/checkpoints/  minimax_h3_hybrid_fl2va_ref2va_b25-49-int8.safetensors"
echo "  - models/loras/        MysticXXX_MMH3-V1.safetensors"
echo "  - models/loras/        minimax_h3_turbo_v4_step600_ema_pruned_comfyui.safetensors"
echo "  - models/upscale_models/minimax_h3_latent_upscaler_3d_fp16.safetensors"

# --- 启动 ComfyUI ---
echo "[INFO] 启动 ComfyUI: $COMFYUI_DIR (端口 $COMFYUI_PORT)"
# shellcheck disable=SC2086
exec "$PYTHON_BIN" main.py \
  --listen 0.0.0.0 \
  --port "$COMFYUI_PORT" \
  $EXTRA_ARGS
