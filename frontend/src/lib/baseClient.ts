// Lightweight in-memory client used by the frontend during development
// No network calls. Exposes basic CRUD-like helpers returning Promises.

type ID = string;

function delay<T>(v: T, ms = 300) {
  return new Promise<T>((res) => setTimeout(() => res(v), ms));
}

const store = {
  helpRequests: [] as any[],
  books: [] as any[],
  announcements: [] as any[],
  users: [] as any[],
};

export const baseClient = {
  list: (collection: keyof typeof store) => delay(store[collection].slice()),
  get: (collection: keyof typeof store, id: ID) => delay(store[collection].find((x) => x.id === id)),
  create: (collection: keyof typeof store, item: any) => {
    store[collection].unshift(item);
    return delay(item);
  },
  update: (collection: keyof typeof store, id: ID, patch: any) => {
    const idx = store[collection].findIndex((x) => x.id === id);
    if (idx === -1) return delay(null);
    store[collection][idx] = { ...store[collection][idx], ...patch };
    return delay(store[collection][idx]);
  },
  remove: (collection: keyof typeof store, id: ID) => {
    const idx = store[collection].findIndex((x) => x.id === id);
    if (idx === -1) return delay(false);
    store[collection].splice(idx, 1);
    return delay(true);
  },
};

export default baseClient;
