import { takeLatest, select, put } from "redux-saga/effects";
import { AUTH_STATE, APP_STATE_ACTION } from "../constants/redux";
import { firebaseSDK } from "../libs/firebase";
import { setAuthState } from "../stores/appSlice";
import { setUser } from "../stores/loginSlice";
import { getUserFromDatabase, saveUserToDatabase } from "../libs/database/user";

const appStateBecomeForground = function* appStateBecomeForground() {
  const auth_state = yield select((state) => state.auth_state);
  if (auth_state == AUTH_STATE.AUTHED) {
  } else {
    const user = yield firebaseSDK.authorizedUser();

    if (user) {
      try {
        const userInfo = yield firebaseSDK.getUser(user.uid);

        yield saveUserToDatabase(userInfo);
        yield put(setUser(userInfo));
        yield put(setAuthState(AUTH_STATE.AUTHED));
      } catch (error) {
        yield put(setAuthState(AUTH_STATE.NOAUTH));
      }
    } else {
      yield put(setAuthState(AUTH_STATE.NOAUTH));
    }
  }
};

const appStateBecomeBackground = function* appStateBecomeBackground() {};

const appStateBecomeInActive = function* appStateBecomeInActive() {};

const root = function* root() {
  yield takeLatest(APP_STATE_ACTION.FOREGROUND, appStateBecomeForground);
  yield takeLatest(APP_STATE_ACTION.BACKGROUND, appStateBecomeBackground);
  yield takeLatest(APP_STATE_ACTION.INACTIVE, appStateBecomeInActive);
};

export default root;
