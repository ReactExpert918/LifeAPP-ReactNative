import { AUTH_ACTION } from "../../constants/redux";
 
const initialState = {
  isSplash: true,
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
    case AUTH_ACTION.UPDATE_SPLASH:
      return { ...state, isSplash: false};
    default: {
      return state;
    }
  }
}

export default Reducer;
