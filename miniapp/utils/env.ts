const baseUrlOverride = (import.meta as any)?.env?.VITE_API_BASE_URL || "";
const fallbackBaseUrl = "https://www.lalaman.cn";

const resolveBaseUrl = (defaultUrl: string) => {
	return baseUrlOverride || defaultUrl;
};

const ENV = {
	development: {
		baseURL: resolveBaseUrl("http://127.0.0.1:8000"),
		envName: "开发环境",
	},
	staging: {
		baseURL: resolveBaseUrl(fallbackBaseUrl),
		envName: "体验版",
	},
	production: {
		baseURL: resolveBaseUrl(fallbackBaseUrl),
		envName: "正式版",
	},
};

export function getAppEnv() {
	let currentEnv = "development";
	// #ifdef MP-WEIXIN
	const accountInfo = wx.getAccountInfoSync();
	/**
	 * accountInfo.miniProgram.envVersion 可取值：
	 * - develop（开发版）
	 * - trial（体验版）
	 * - release（正式版）
	 */
	currentEnv = accountInfo.miniProgram.envVersion;
	// #endif

	switch (currentEnv) {
		case "develop":
			return "development";
		case "trial":
			return "staging";
		case "release":
			return "production";
		default:
			return "development";
	}
}

export default ENV;
