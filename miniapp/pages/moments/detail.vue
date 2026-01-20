<template>
	<view class="moment-detail">
		<Header :title="'片刻'" />
		<view class="media">
			<video v-if="moment?.assets?.mp4_url" :src="moment.assets.mp4_url" controls object-fit="cover" />
			<image v-else class="photo" :src="moment?.render?.preview_url || moment?.assets?.photo_url" mode="widthFix" />
			<audio v-if="!moment?.assets?.mp4_url" :src="moment?.assets?.audio_url" controls />
		</view>
		<view class="status" v-if="moment?.render?.status">
			<text class="badge" :class="moment.render.status">{{ statusLabel }}</text>
			<text class="hint" v-if="moment?.render?.error">{{ moment.render.error }}</text>
			<button class="refresh" :disabled="isRefreshing" @click="manualRefresh">刷新状态</button>
		</view>
		<view class="status" v-else>
			<text class="badge pending">等待生成</text>
		</view>
		<view class="status-actions" v-if="momentId && showDevTools">
			<text class="label">开发：快速切换状态</text>
			<view class="buttons">
				<button class="pill" @click="updateRender('rendering')">生成中</button>
				<button class="pill" @click="updateRender('ready')">完成</button>
				<button class="pill" @click="updateRender('failed')">失败</button>
			</view>
		</view>
		<view class="meta">
			<view class="title">{{ (moment?.mood_emoji || '') + ' ' + (moment?.title || '片刻') }}</view>
			<view class="sub">{{ moment?.geo?.zone_name || '附近' }}</view>
		</view>
		<view class="author-actions" v-if="momentId">
			<view class="action-row">
				<text class="label">可见性</text>
				<button class="pill" :disabled="isUpdatingVisibility" @click="toggleVisibility">
					{{ visibilityLabel }}
				</button>
			</view>
			<view class="action-row danger">
				<text class="label">删除片刻</text>
				<button class="pill danger" :disabled="isDeleting" @click="confirmDelete">删除</button>
			</view>
			<view class="action-row">
				<text class="label">导出/分享</text>
				<button class="pill ghost" @click="handleShare">导出</button>
			</view>
			<view class="action-row" v-if="moment?.render?.status === 'failed'">
				<text class="label">生成失败</text>
				<button class="pill ghost" :disabled="isRetrying" @click="retryRender">再试一次</button>
			</view>
		</view>
	</view>
</template>

<script lang="ts">
import Header from '@/components/Header.vue';
import apiMoments from '@/api/moments';
import apiDev from '@/api/dev';

export default {
	components: {
		Header,
	},
	data() {
		return {
			moment: null,
			momentId: '',
			isRefreshing: false,
			pollTimer: null,
			isUpdatingVisibility: false,
			isDeleting: false,
			isRetrying: false,
		};
	},
	computed: {
		showDevTools() {
			return process.env.NODE_ENV !== 'production';
		},
		visibilityLabel() {
			return this.moment?.visibility === 'public_anonymous' ? '匿名公开' : '仅自己';
		},
		statusLabel() {
			switch (this.moment?.render?.status) {
				case 'rendering':
					return '生成中...';
				case 'pending':
					return '等待生成';
				case 'ready':
					return '生成完成';
				case 'failed':
					return '生成失败';
				default:
					return '';
			}
		},
	},
	onLoad(options: Record<string, string>) {
		const { id } = options || {};
		if (id) {
			this.momentId = id;
			this.fetchMoment(id);
			this.startPolling();
		}
	},
	onUnload() {
		this.stopPolling();
	},
	methods: {
		async fetchMoment(id: string) {
			const res = await apiMoments.detail(id);
			this.moment = res?.moment || res;
			if (this.moment?.render?.status === 'ready' || this.moment?.render?.status === 'failed') {
				this.stopPolling();
			}
		},
		startPolling() {
			if (this.pollTimer || !this.momentId) return;
			this.pollTimer = setInterval(() => {
				if (this.momentId && !this.isRefreshing) {
					this.fetchMoment(this.momentId);
				}
			}, 10000);
		},
		stopPolling() {
			if (this.pollTimer) {
				clearInterval(this.pollTimer);
				this.pollTimer = null;
			}
		},
		async manualRefresh() {
			if (!this.momentId) return;
			this.isRefreshing = true;
			try {
				await this.fetchMoment(this.momentId);
			} finally {
				this.isRefreshing = false;
			}
		},
		async updateRender(status: string) {
			if (!this.momentId) return;
			try {
				await apiDev.updateRenderStatus(this.momentId, { status });
				await this.fetchMoment(this.momentId);
			} catch (err) {
				console.error(err);
				uni.showToast({ title: '更新失败', icon: 'none' });
			}
		},
		handleShare() {
			uni.showActionSheet({
				itemList: ['保存到相册（占位）', '系统分享（占位）'],
			});
		},
		async retryRender() {
			if (!this.momentId) return;
			this.isRetrying = true;
			try {
				if (this.showDevTools) {
					await apiDev.updateRenderStatus(this.momentId, { status: 'rendering' });
					await this.fetchMoment(this.momentId);
				} else {
					uni.showToast({ title: '已触发重试（占位）', icon: 'none' });
				}
			} catch (err) {
				console.error(err);
				uni.showToast({ title: '重试失败', icon: 'none' });
			} finally {
				this.isRetrying = false;
			}
		},
		async toggleVisibility() {
			if (!this.momentId || !this.moment?.visibility) return;
			const nextVisibility =
				this.moment.visibility === 'public_anonymous' ? 'private' : 'public_anonymous';
			this.isUpdatingVisibility = true;
			try {
				await apiMoments.updateVisibility(this.momentId, { visibility: nextVisibility });
				await this.fetchMoment(this.momentId);
			} catch (err) {
				console.error(err);
				uni.showToast({ title: '更新失败', icon: 'none' });
			} finally {
				this.isUpdatingVisibility = false;
			}
		},
		confirmDelete() {
			if (!this.momentId) return;
			uni.showModal({
				title: '删除片刻',
				content: '删除后无法恢复，确认删除？',
				confirmText: '删除',
				confirmColor: '#111',
				success: async (res) => {
					if (!res.confirm) return;
					this.isDeleting = true;
					try {
						await apiMoments.delete(this.momentId);
						uni.showToast({ title: '已删除', icon: 'none' });
						setTimeout(() => uni.navigateBack(), 300);
					} catch (err) {
						console.error(err);
						uni.showToast({ title: '删除失败', icon: 'none' });
					} finally {
						this.isDeleting = false;
					}
				},
			});
		},
	},
};
</script>

<style scoped>
.moment-detail {
	background-color: #fff;
	min-height: 100vh;
}

.media {
	padding: 40rpx 32rpx;
}

.photo,
video {
	width: 100%;
	border-radius: 24rpx;
	overflow: hidden;
}

audio {
	width: 100%;
	margin-top: 24rpx;
}

.meta {
	padding: 0 32rpx 40rpx;
}

.status {
	padding: 0 32rpx 20rpx;
	display: flex;
	align-items: center;
	gap: 12rpx;
}

.badge {
	padding: 8rpx 16rpx;
	border-radius: 999rpx;
	font-size: 24rpx;
	background: #f2f2f2;
	color: #333;
}

.badge.rendering,
.badge.pending {
	background: #111;
	color: #fff;
}

.badge.failed {
	background: #ffeaea;
	color: #b42318;
}

.badge.ready {
	background: #e7f6ec;
	color: #0f5132;
}

.hint {
	font-size: 22rpx;
	color: #b42318;
}

.refresh {
	margin-left: auto;
	padding: 8rpx 16rpx;
	border-radius: 999rpx;
	background: #f2f2f2;
	font-size: 22rpx;
	color: #111;
}

.status-actions {
	padding: 0 32rpx 20rpx;
}

.status-actions .label {
	font-size: 22rpx;
	color: #777;
}

.status-actions .buttons {
	display: flex;
	gap: 12rpx;
	margin-top: 12rpx;
}

.status-actions .pill {
	padding: 8rpx 16rpx;
	border-radius: 999rpx;
	background: #f2f2f2;
	font-size: 22rpx;
	color: #111;
}

.title {
	font-size: 32rpx;
	font-weight: 600;
	color: #111;
}

.sub {
	margin-top: 12rpx;
	font-size: 24rpx;
	color: #666;
}

.author-actions {
	padding: 0 32rpx 40rpx;
	display: flex;
	flex-direction: column;
	gap: 16rpx;
}

.action-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 16rpx 20rpx;
	border-radius: 16rpx;
	background: #f7f7f7;
}

.action-row.danger {
	background: #fff5f5;
}

.action-row .label {
	font-size: 24rpx;
	color: #333;
}

.pill {
	padding: 8rpx 18rpx;
	border-radius: 999rpx;
	background: #111;
	color: #fff;
	font-size: 22rpx;
}

.pill.ghost {
	background: #fff;
	color: #111;
	border: 2rpx solid #111;
}

.pill.danger {
	background: #c62828;
}
</style>
