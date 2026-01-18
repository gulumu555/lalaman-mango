<template>
	<view class="moment-detail">
		<Header :title="'片刻'" />
		<view class="media">
			<video v-if="moment?.assets?.mp4_url" :src="moment.assets.mp4_url" controls object-fit="cover" />
			<image v-else class="photo" :src="moment?.assets?.photo_url" mode="widthFix" />
			<audio v-if="!moment?.assets?.mp4_url" :src="moment?.assets?.audio_url" controls />
		</view>
		<view class="meta">
			<view class="title">{{ (moment?.mood_emoji || '') + ' ' + (moment?.title || '片刻') }}</view>
			<view class="sub">{{ moment?.geo?.zone_name || '附近' }}</view>
		</view>
	</view>
</template>

<script lang="ts">
import Header from '@/components/Header.vue';
import apiMoments from '@/api/moments';

export default {
	components: {
		Header,
	},
	data() {
		return {
			moment: null,
		};
	},
	onLoad(options: Record<string, string>) {
		const { id } = options || {};
		if (id) {
			this.fetchMoment(id);
		}
	},
	methods: {
		async fetchMoment(id: string) {
			const res = await apiMoments.detail(id);
			this.moment = res?.moment || res;
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
</style>
