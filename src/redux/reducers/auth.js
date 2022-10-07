/* eslint-disable indent */
import { AUTH_ACTION } from '../../constants/redux';

const initialState = {
  user: {},
  isLogin: false,
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
    case AUTH_ACTION.USER_LOGIN:
      return { ...state, ...action.payload, isLogin: true };
    case AUTH_ACTION.USER_LOGOUT:
      return { ...state, isLogin: false };
    default: {
      return state;
    }
  }
};

export default Reducer;
