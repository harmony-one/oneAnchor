import { ToastActionTypes } from "./toast.types";

const INITIAL_STATE = {
  toast: null
}

const toastReducer = (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case ToastActionTypes.SET_TOAST_MESSAGE:
      return {
        ...state,
        toast: action.payload
      }
    default: 
      return state;
  }
}

export default toastReducer;