const BASE = import.meta.env.VITE_API_BASE || "/api";

async function request(path, opts = {}) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { "Content-Type": "application/json", ...(opts.headers || {}) },
    ...opts
  });
  if (res.status === 204) return null;
  const text = await res.text();
  const data = text ? JSON.parse(text) : null;
  if (!res.ok) throw new Error(data?.error || `HTTP ${res.status}`);
  return data;
}

export const api = {
  get:    (p)        => request(p),
  post:   (p, body)  => request(p, { method: "POST",   body: JSON.stringify(body || {}) }),
  patch:  (p, body)  => request(p, { method: "PATCH",  body: JSON.stringify(body || {}) }),
  del:    (p)        => request(p, { method: "DELETE" })
};

export const rooms = {
  list:   ()        => api.get("/rooms"),
  create: (data)    => api.post("/rooms", data),
  update: (id, d)   => api.patch(`/rooms/${id}`, d),
  remove: (id)      => api.del(`/rooms/${id}`)
};

export const guests = {
  list:   ()        => api.get("/guests"),
  create: (data)    => api.post("/guests", data),
  update: (id, d)   => api.patch(`/guests/${id}`, d),
  remove: (id)      => api.del(`/guests/${id}`)
};

export const reservations = {
  list:    ()       => api.get("/reservations"),
  create:  (data)   => api.post("/reservations", data),
  update:  (id, d)  => api.patch(`/reservations/${id}`, d),
  remove:  (id)     => api.del(`/reservations/${id}`),
  checkIn: (id)     => api.post(`/reservations/${id}/check_in`)
};

export const stays = {
  list:     (active) => api.get(active ? "/stays?active=true" : "/stays"),
  checkOut: (id)     => api.post(`/stays/${id}/check_out`)
};
