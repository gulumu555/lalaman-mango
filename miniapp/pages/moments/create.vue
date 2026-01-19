<template>
	<view class="moment-create">
		<Header :title="'创建片刻'" />
		<view class="section">
			<view class="label">照片</view>
			<image v-if="photoPath" class="photo" :src="photoPath" mode="widthFix" />
			<button class="btn" @click="pickPhoto">选择照片</button>
		</view>
		<view class="section">
			<view class="label">标题</view>
			<input class="input" v-model="title" placeholder="给这一刻起个名字" />
		</view>
		<view class="section">
			<view class="label">情绪</view>
			<view class="moods">
				<button v-for="item in moods" :key="item.code" class="pill"
					:class="{ active: moodCode === item.code }" @click="moodCode = item.code">
					{{ item.label }}
				</button>
			</view>
		</view>
		<view class="section">
			<view class="label">语音（必填）</view>
			<view class="audio-actions">
				<button class="btn" :disabled="recording" @click="startRecord">开始录音</button>
				<button class="btn-secondary" :disabled="!recording" @click="stopRecord">停止录音</button>
			</view>
			<view class="audio-info" v-if="audioPath">
				已录音 {{ audioDuration }} 秒
			</view>
		</view>
		<view class="section">
			<view class="label">发布范围</view>
			<switch :checked="visibility === 'public_anonymous'" @change="toggleVisibility" />
			<text class="hint">匿名公开</text>
		</view>
		<view class="section" v-if="renderStatus">
			<view class="label">生成状态</view>
			<view class="status" :class="renderStatus">
				{{ renderStatusLabel }}
			</view>
			<view class="status-hint" v-if="renderError">
				{{ renderError }}
			</view>
		</view>
		<button class="primary" :disabled="submitting" @click="submit">发布片刻</button>
	</view>
</template>

<script lang="ts">
import Header from '@/components/Header.vue';
import { chooseImage } from '@/utils/upload';
import apiMoments from '@/api/moments';

export default {
	components: {
		Header,
	},
	data() {
		return {
			photoPath: '',
			title: '',
			moodCode: 'light',
			visibility: 'private',
			submitting: false,
			audioPath: '',
			audioDuration: 0,
			recording: false,
			recorderManager: null,
			renderStatus: '',
			renderError: '',
			moods: [
				{ code: 'light', label: '🙂轻松' },
				{ code: 'healing', label: '🫧治愈' },
				{ code: 'luck', label: '✨小确幸' },
				{ code: 'tired', label: '😮‍💨疲惫' },
				{ code: 'emo', label: '🥲emo' },
			],
		};
	},
	onLoad(options: Record<string, string>) {
		if (options?.photo) {
			this.photoPath = decodeURIComponent(options.photo);
		}
		const recorderManager = uni.getRecorderManager();
		recorderManager.onStop((res: any) => {
			this.recording = false;
			this.audioPath = res.tempFilePath || '';
			this.audioDuration = Math.max(1, Math.round((res.duration || 0) / 1000));
		});
		recorderManager.onError(() => {
			this.recording = false;
			uni.showToast({ title: '录音失败', icon: 'none' });
		});
		this.recorderManager = recorderManager;
	},
	methods: {
		async pickPhoto() {
			const tmpUrl = await chooseImage();
			if (tmpUrl) {
				this.photoPath = tmpUrl;
			}
		},
		startRecord() {
			if (!this.recorderManager) return;
			this.recording = true;
			this.audioPath = '';
			this.audioDuration = 0;
			this.recorderManager.start({
				duration: 15000,
				format: 'mp3',
			});
		},
		stopRecord() {
			if (!this.recorderManager) return;
			this.recorderManager.stop();
		},
		toggleVisibility(e: any) {
			this.visibility = e.detail.value ? 'public_anonymous' : 'private';
		},
		async submit() {
			if (!this.photoPath) {
				uni.showToast({ title: '请先选择照片', icon: 'none' });
				return;
			}
			if (!this.audioPath) {
				uni.showToast({ title: '请先录一段语音', icon: 'none' });
				return;
			}
			this.submitting = true;
			this.renderStatus = 'rendering';
			this.renderError = '';
			try {
				const payload = {
					title: this.title,
					mood_code: this.moodCode,
					visibility: this.visibility,
					geo: { lat: 30.6570, lng: 104.0800, zone_name: '成都', radius_m: 3000 },
					motion_template_id: 'T02_Cloud',
					pony: false,
					render_status: 'rendering',
					assets: {
						photo_url: this.photoPath,
						audio_url: this.audioPath,
						mp4_url: null,
						thumb_url: null,
						duration_s: this.audioDuration || 4.0,
					},
				};
				const res = await apiMoments.create(payload);
				const momentId = res?.id || res?.data?.id;
				this.renderStatus = 'pending';
				uni.showToast({ title: '已发布', icon: 'success' });
				if (momentId) {
					uni.navigateTo({ url: `/pages/moments/detail?id=${momentId}` });
				}
			} catch (err) {
				console.error(err);
				this.renderStatus = 'failed';
				this.renderError = '生成失败，请稍后再试';
				uni.showToast({ title: '发布失败', icon: 'none' });
			} finally {
				this.submitting = false;
			}
		},
	},
	computed: {
		renderStatusLabel() {
			switch (this.renderStatus) {
				case 'rendering':
					return '生成中...';
				case 'pending':
					return '已提交，等待生成';
				case 'ready':
					return '生成完成';
				case 'failed':
					return '生成失败';
				default:
					return '';
			}
		},
	},
};
</script>

<style scoped>
.moment-create {
	background-color: #fff;
	min-height: 100vh;
	padding: 24rpx 32rpx 80rpx;
}

.section {
	margin-bottom: 32rpx;
}

.label {
	font-size: 26rpx;
	color: #444;
	margin-bottom: 12rpx;
}

.photo {
	width: 100%;
	border-radius: 24rpx;
	margin-bottom: 16rpx;
}

.input {
	width: 100%;
	background: #f6f6f6;
	border-radius: 16rpx;
	padding: 20rpx;
}

.moods {
	display: flex;
	flex-wrap: wrap;
	gap: 12rpx;
}

.pill {
	padding: 12rpx 20rpx;
	border-radius: 999rpx;
	background: #f2f2f2;
	font-size: 24rpx;
}

.pill.active {
	background: #111;
	color: #fff;
}

.btn {
	background: #111;
	color: #fff;
	border-radius: 16rpx;
	margin-top: 12rpx;
}

.btn-secondary {
	background: #f2f2f2;
	color: #111;
	border-radius: 16rpx;
	margin-top: 12rpx;
	margin-left: 12rpx;
}

.audio-actions {
	display: flex;
	align-items: center;
}

.audio-info {
	margin-top: 12rpx;
	font-size: 24rpx;
	color: #666;
}

.primary {
	background: #111;
	color: #fff;
	border-radius: 24rpx;
	margin-top: 24rpx;
}

.hint {
	margin-left: 12rpx;
	font-size: 24rpx;
	color: #666;
}

.status {
	display: inline-flex;
	align-items: center;
	padding: 8rpx 16rpx;
	border-radius: 999rpx;
	font-size: 24rpx;
	background: #f2f2f2;
	color: #333;
}

.status.rendering,
.status.pending {
	background: #111;
	color: #fff;
}

.status.failed {
	background: #ffeaea;
	color: #b42318;
}

.status.ready {
	background: #e7f6ec;
	color: #0f5132;
}

.status-hint {
	margin-top: 8rpx;
	font-size: 22rpx;
	color: #b42318;
}
</style>
