import request from "@/utils/request";

export default {
	nearby: (params: Record<string, any>) => {
		return request.get("/api/moments/nearby", params);
	},
	detail: (id: string) => {
		return request.get(`/api/moments/${id}`);
	},
	create: (payload: Record<string, any>) => {
		return request.post("/api/moments", payload);
	},
};
