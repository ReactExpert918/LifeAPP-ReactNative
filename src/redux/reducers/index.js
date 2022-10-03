import { combineReducers } from 'redux';
import AsyncStorage from '@react-native-community/async-storage';
import persistReducer from 'redux-persist/es/persistReducer';

// import { AUTH_ACTION, AUTH_STATE } from "../../constants/redux";
import Home from './homeReducer';
import Auth from './authReducer';

const persistConfig = {
  key: 'root',
  storage: AsyncStorage,
  version: 1,
  whitelist: ['Login'],
};

export const CombinedReducer = combineReducers({
  Auth: persistReducer(persistConfig, Auth),
  Home,
});

const rootReducer = (state, action) => {
  // when a logout action is dispatched it will reset redux state
  // if (action.type === AUTH_ACTION.USER_LOGOUT) {
  //   const {Home} = state;

  //   state = {Home};
  // }

  return CombinedReducer(state, action);
};

export default rootReducer;
