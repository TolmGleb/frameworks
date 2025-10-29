import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Добавляем токен к каждому запросу
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Обрабатываем ошибки авторизации
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
};

export const defectsAPI = {
  getAll: (filters = {}) => api.get('/defects', { params: filters }),
  create: (defectData) => api.post('/defects', defectData),
  updateStatus: (id, status) => api.patch(`/defects/${id}/status`, { status }),
  getComments: (defectId) => api.get(`/defects/${defectId}/comments`),
  addComment: (defectId, comment) => api.post(`/defects/${defectId}/comments`, comment),
};

export const projectsAPI = {
  getAll: () => api.get('/projects'),
  getStats: () => api.get('/projects/stats'),
};

export const usersAPI = {
  getAll: () => api.get('/users'),
  getEngineers: () => api.get('/users/engineers'),
};

export default api;