import { AUTH_ACTION } from '../../constants/redux';

export const logOut = () => ({
  type: AUTH_ACTION.USER_LOGOUT,
});
