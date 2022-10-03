import { combineReducers } from 'redux';

import Home from './home';
import Auth from './auth';
import { AUTH_ACTION } from '../../constants/redux';

export const CombinedReducer = combineReducers({
  Auth,
  Home,
});

const rootReducer = (state, action) => {
  // when a logout action is dispatched it will reset redux state
  if (action.type === AUTH_ACTION.USER_LOGOUT) {
    const { Auth } = state;

    state = { Auth };
  }

  return CombinedReducer(state, action);
};

export default rootReducer;
