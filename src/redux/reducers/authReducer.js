import { Action } from "../../constants";
import { AUTH_ACTION, AUTH_STATE } from "../../constants/redux";
 
const initialState = {
  user: {},
  isLogined: false,
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
    case AUTH_ACTION.USER_LOGIN:
      return { ...state, ...action.payload };
    case AUTH_ACTION.USER_LOGOUT:
      return { ...state, isLogined: false }
    default: {
      return null;
    }
  }
}

export default Reducer;
