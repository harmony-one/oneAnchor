import { ToastActionTypes } from './toast.types';

export const setToastMessage = toast => {
  return {
    type: ToastActionTypes.SET_TOAST_MESSAGE,
    payload: toast
  }
}
