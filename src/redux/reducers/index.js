import { combineReducers } from 'redux';
import AsyncStorage from '@react-native-community/async-storage';
import persistReducer from 'redux-persist/es/persistReducer';

import { Action } from '../../constants';
import Home from './homeReducer';
import Auth from './authReducer';

const homePersistConfig = {
  key: 'Home',
  storage: AsyncStorage,
  whitelist: ['myFilter'],
  blacklist: [],
};

const CombinedReducer = combineReducers({
  Home: persistReducer(homePersistConfig, Home),
  Auth,
});

const rootReducer = (state, action) => {
  // when a logout action is dispatched it will reset redux state
  if (action.type === Action.USER_LOGOUT) {
    const {Home} = state;

    state = {Home};
  }

  return CombinedReducer(state, action);
};

export default rootReducer;
