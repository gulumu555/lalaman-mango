<template>
	<Header icon="/static/options.svg" :iconTitle="configInfo?.title" :back="() => navigatorTo('/pages/user/index')">
	</Header>
	<view class="content">
		<image class="logo" src="/static/logo.svg" mode="aspectFit"
			:style="{ 'transform': `translate(-50%,${statusBarHeight * scale}px) scale(${scale})` }"></image>
		<view class="mood-card" v-if="moodWeather?.summary?.length">
			<view class="mood-title">情绪天气</view>
			<view class="mood-list">
				<view
					v-for="item in moodWeather.summary"
					:key="item.mood_code"
					class="mood-item"
					:class="{ selected: selectedMood === item.mood_code }"
					@click="setMoodFilter(item.mood_code)"
				>
					<text class="emoji">{{ item.mood_emoji }}</text>
					<text class="label">{{ item.mood_code }}</text>
					<text class="percent">{{ item.percent }}%</text>
				</view>
			</view>
			<button class="mood-clear" v-if="selectedMood" @click="clearMoodFilter">清除筛选</button>
		</view>
		<InfiniteList :fetchFn="requestData" :scroll="handleScroll" :params="{ mood_code: selectedMood }"
			:styles="{ width: '100%', height: 'calc(100vh - 47px - 78rpx)' }">
			<template #default="{ item, index }">
				<view style="padding-top: 246rpx;background-color: #fff;" v-if="index === 0"></view>
				<view class="image-list" @click="openMoment(item.id)">
					<image class="image" :src="getThumbnailUrl(item?.assets?.photo_url || item?.photo_url, 500)" mode="widthFix"></image>
					<view class="desc">
						{{ (item.mood_emoji || '') + ' ' + (item.title || item.geo?.zone_name || '片刻') }}
					</view>
				</view>
			</template>
		</InfiniteList>
	</view>
	<view class="footer-float-wrapper" v-show="isLoadedUser">
		<!-- shopping 图标 -->
		<!-- <template v-if="loggedIn">
			<image class="user" src="/static/shopping.svg" mode="aspectFit" @click="handleChooseImage('print')" />
		</template>
		<template v-else>
			<button open-type="getPhoneNumber"
				@getphonenumber="e => handleGetPhoneNumber(e, handleChooseImage('print'))" class="clean-button">
				<image class="user" src="/static/shopping.svg" mode="aspectFit" />
			</button>
		</template> -->
		<image class="user" src="/static/shopping.svg" mode="aspectFit" @click="uni.showModal({
			title: '敬请期待',
			showCancel: false
		})" />


		<!-- addition 图标 -->
		<template v-if="loggedIn">
			<image class="addition" src="/static/addition.svg" mode="aspectFit" @click="openCreate" />
		</template>
		<template v-else>
			<button open-type="getPhoneNumber" @getphonenumber="e => handleGetPhoneNumber(e, openCreate)"
				class="clean-button">
				<image class="addition" src="/static/addition.svg" mode="aspectFit" />
			</button>
		</template>

		<!-- user 图标 -->
		<template v-if="loggedIn">
			<image class="user" src="/static/user.svg" mode="aspectFit" @click="navigatorTo('/pages/user/index')" />
		</template>
		<template v-else>
			<button open-type="getPhoneNumber"
				@getphonenumber="e => handleGetPhoneNumber(e, () => navigatorTo('/pages/user/index'))"
				class="clean-button">
				<image class="user" src="/static/user.svg" mode="aspectFit" />
			</button>
		</template>
	</view>
</template>

<script lang="ts">
	import Header from '@/components/Header.vue'
	import InfiniteList from '@/components/InfiniteList.vue'
	import { autoLogin, login, loginGetPhoneNumber } from '@/utils/user'
	import { checkLoginThen, getThumbnailUrl } from '@/utils/base'
	import { getLocalToken } from '@/utils/user'
	import { chooseImage } from '@/utils/upload'
	import apiUser from '@/api/user'
	import apiMoments from '@/api/moments'
		export default {
		components: {
			Header,
			InfiniteList,
		},
		data() {
			return {
				getThumbnailUrl,
				title: 'Hello',
				code: '',
				dataList: [],
				chooseData: [],
				openChooseImage: false,
				loggedIn: false,
				statusBarHeight: uni.getSystemInfoSync().statusBarHeight,
				scale: 1,
				isLoadedUser: false,
				configInfo: {},
				centerLat: 30.6570,
				centerLng: 104.0800,
				radiusM: 3000,
				moodWeather: null,
				selectedMood: ''
			}
		},
		onLoad(options) {
			this.initPid(options)
			this.getConfig();
			autoLogin().then((res) => {
				if (res?.data?.is_register === 1) {
					this.loggedIn = !!getLocalToken()
				}
			}).finally(() => {
				this.isLoadedUser = true
			})
		},
		methods: {
			getConfig() {
				apiUser.getConfig().then(res => {
					this.configInfo = res.data
				})
			},
			initPid(options) {
				const { pid = 0, scene } = options || {}
				if (scene) {
					try {
						const decoded = decodeURIComponent(scene)
						const sceneParams = {}
						decoded.split('&').forEach(pair => {
							const [key, val] = pair.split('=')
							sceneParams[key] = val
						})
						const from_id = decodeURIComponent(sceneParams?.from_id || pid)

						if (from_id)
							uni.setStorageSync('pid', from_id)
						else
							uni.setStorageSync('pid', 0)
					} catch (error) {
						console.error('解析scene参数失败:', error)
						uni.setStorageSync('pid', pid || 0)
					}
				} else {
					uni.setStorageSync('pid', pid || 0)
				}
			},
			async handleGetPhoneNumber(e, callback) {
				if (e.detail.errMsg !== 'getPhoneNumber:ok') {
					uni.showToast({
						title: '授权失败',
						icon: 'none'
					})
					return
				}
				const autoLoginRes = await autoLogin()
				const { is_register, token: autoLoginToken = '' } = autoLoginRes || {}
				if (is_register === 1 && autoLoginToken) return

				const loginGetRes = await loginGetPhoneNumber(e.detail.code)
				const token = loginGetRes?.data?.token || ''
				if (token) {
					this.loggedIn = getLocalToken()
					callback && callback()
				}
			},
			async requestData(params = {}) {
				const moodCode = params?.mood_code || this.selectedMood;
				const res = await apiMoments.nearby({
					lat: this.centerLat,
					lng: this.centerLng,
					radius_m: this.radiusM,
					visibility: 'public_anonymous',
					mood_code: moodCode || undefined,
				});
				const items = res?.items || res?.data?.items || [];
				this.moodWeather = res?.mood_weather || res?.data?.mood_weather || this.moodWeather;
				return { data: { current_page: 1, last_page: 1, data: items } };
			},
			setMoodFilter(code: string) {
				if (this.selectedMood === code) return;
				this.selectedMood = code;
			},
			clearMoodFilter() {
				if (!this.selectedMood) return;
				this.selectedMood = '';
			},
			navigatorTo(url : string) {
				checkLoginThen(() => {
					uni.navigateTo({ url });
				});
			},
			async handleChooseImage(type) {
				const tmpUrl = await chooseImage();
				if (!tmpUrl) return;
				const baseUrl =
					type === "print"
						? "/pages/print/index?categoryOriginId=1&url="
						: "/pages/styleTransfer/index?categoryOriginId=2&url=";
				const fullUrl = `${baseUrl}${encodeURIComponent(tmpUrl)}`;
				uni.navigateTo({
					url: fullUrl,
				});
			},
							openMoment(id) {
					if (!id) return;
					uni.navigateTo({ url: `/pages/moments/detail?id=${id}` });
				},
				openCreate() {
					chooseImage().then(tmpUrl => {
						if (!tmpUrl) return;
						const fullUrl = `/pages/moments/create?photo=${encodeURIComponent(tmpUrl)}`;
						uni.navigateTo({ url: fullUrl });
					});
				},
handleCancelChooseImage() {
				this.openChooseImage = false;
			},
			handleScroll(e) {
				const scrollTop = e.detail.scrollTop;
				const minScale = 0.7;
				const maxScale = 1;
				const threshold = 300;

				const scale = Math.max(minScale, maxScale - scrollTop / threshold);
				this.scale = scale;
			}
		},
	}
</script>

<style lang="less" scoped>
	@height: 246rpx;

	.content {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		position: relative;
	}

	.mood-card {
		width: calc(100% - 64rpx);
		margin: 24rpx 32rpx 0;
		padding: 20rpx 24rpx;
		border-radius: 24rpx;
		background: #f7f5f0;
		box-shadow: 0 12rpx 28rpx rgba(0, 0, 0, 0.08);
	}

	.mood-title {
		font-size: 26rpx;
		color: #4a4a4a;
		margin-bottom: 16rpx;
	}

	.mood-list {
		display: flex;
		flex-wrap: wrap;
		gap: 16rpx;
	}

	.mood-item {
		flex: 1 1 calc(50% - 16rpx);
		min-width: 200rpx;
		padding: 14rpx 16rpx;
		border-radius: 18rpx;
		background: #fff;
		display: flex;
		flex-direction: column;
		gap: 6rpx;
		border: 2rpx solid transparent;
	}

	.mood-item.selected {
		border-color: #111;
		background: #fff7e6;
	}

	.mood-item .emoji {
		font-size: 30rpx;
	}

	.mood-item .label {
		font-size: 22rpx;
		color: #333;
	}

	.mood-item .percent {
		font-size: 20rpx;
		color: #777;
	}

	.mood-clear {
		margin-top: 16rpx;
		padding: 10rpx 16rpx;
		border-radius: 999rpx;
		background: #111;
		color: #fff;
		font-size: 22rpx;
	}

	.logo {
		width: 98rpx;
		height: 98rpx;
		position: fixed;
		left: 50%;
		top: 140rpx;
		z-index: 9;
		transition: transform 0.1s ease;
	}

	.image-list {
		position: relative;

		.image {
			width: 100vw;
			display: block;
		}

		.desc {
			position: absolute;
			left: 0;
			bottom: 50rpx;
			width: 100vw;
			text-align: center;
			font-size: 24rpx;
			color: #fff;
			text-shadow: 0px 2px 2px rgba(0, 0, 0, 0.25);
		}
	}

	.btn-user {
		background-color: transparent;
		padding: 0;
		margin: 0;

		&::after {
			border: none;
		}
	}

	.footer-float-wrapper {
		bottom: 88rpx;
		left: 28rpx;
		right: 28rpx;

		.user {
			width: 138rpx;
			height: 138rpx;
		}

		.addition {
			width: 216rpx;
			height: 216rpx;
		}
	}
</style>
