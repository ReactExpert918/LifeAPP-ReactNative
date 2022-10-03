import { AUTH_ACTION } from "../../constants/redux";
 
const initialState = {
  user: {},
  isLogin: false,
  isSplash: true,
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
    case AUTH_ACTION.USER_LOGIN:
      return { ...state, ...action.payload };
    case AUTH_ACTION.USER_LOGOUT:
      return { ...state, isLogin: false };
    case AUTH_ACTION.UPDATE_SPLASH:
      return { ...state, isSplash: false};
    default: {
      return state;
    }
  }
}

export default Reducer;
