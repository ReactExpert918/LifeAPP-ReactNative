import {
  checkAuthedUser,
  signInEmailPassword,
  signOut,
  signInWithPhoneNumber,
  getCredential,
  linkCredential,
  updateEmail,
  updatePassword,
  updateDisplayName,
  authorizedUser,
  deleteAuthedUser,
} from "./auth";

import { uploadMedia, uploadAvata, getDownloadURL } from "./storage";
import {
  getUser,
  deleteUser,
  setUser,
  getUsers,
  getMembers,
  getGroups,
  getGroup,
  getFriends,
  getSingles,
  getLastMessasge,
} from "./firestore";

export const firebaseSDK = {
  checkAuthedUser,
  signInEmailPassword,
  signOut,
  signInWithPhoneNumber,
  getCredential,
  linkCredential,
  updateEmail,
  updatePassword,
  updateDisplayName,
  authorizedUser,
  deleteAuthedUser,

  uploadMedia,
  uploadAvata,
  getDownloadURL,

  getUser,
  getUsers,
  deleteUser,
  setUser,
  getMembers,
  getGroups,
  getGroup,
  getFriends,
  getLastMessasge,
  getSingles,
};
