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
  getMembers,
  getGroups,
  getFriends,
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
  deleteUser,
  setUser,
  getMembers,
  getGroups,
  getFriends,
};
