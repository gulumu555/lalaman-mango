import request from "@/utils/request";

export default {
	updateRenderStatus: (id: string, payload: Record<string, any>) => {
		return request.post(`/api/dev/moments/${id}/render`, payload);
	},
};
