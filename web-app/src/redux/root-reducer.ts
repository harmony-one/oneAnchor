import { combineReducers } from "redux";

import toastReducer from "./toast/toast.reducer";

export const rootReducer = combineReducers({
  toast: toastReducer
});

export type RootState = ReturnType<typeof rootReducer>;