import { Action } from "../../constants";

const initialState = {
  user: {},
  isLogined: false,
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
    case Action.USER_LOGIN:
      return { ...state, ...action.payload };
    case Action.USER_LOGOUT:
      return { ...state, isLogined: false }
  }
}

export default Reducer;
