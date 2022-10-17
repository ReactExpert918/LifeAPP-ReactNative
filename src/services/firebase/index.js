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
} from './auth';

import { uploadMedia, uploadAvata, getDownloadURL } from './storage';
import {
  updateEmailAddress,
  updateFullName,
  updatePhoneNumber,
  checkUserName,
  updateUserName,
  getUser,
  deleteUser,
  updateToken,
  createUser,
  setUser,
  getUsers,
  getUserWithName,
  getUserWithPhonenumber,
  getMembers,
  getGroups,
  getGroup,
  getNewFriends,
  acceptFriend,
  getRecommandFriends,
  createSingle,
  declineFriend,
  getFriends,
  checkFriend,
  creatFriend,
  deleteFriend,
  getSingles,
  getPerson,
  getLastMessasge,
  createMessage,
  getSingle,
  getZedPay,
  getSingleChats,
} from './firestore';

import { setFcmToken } from './message';

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

  updateFullName,
  updateEmailAddress,
  updatePhoneNumber,
  updateUserName,
  checkUserName,
  createUser,
  getUser,
  getUsers,
  getUserWithName,
  createSingle,
  getUserWithPhonenumber,
  deleteUser,
  setUser,
  getMembers,
  getGroups,
  getGroup,
  getNewFriends,
  getFriends,
  checkFriend,
  creatFriend,
  deleteFriend,
  getLastMessasge,
  createMessage,
  getSingles,
  getPerson,
  getSingle,
  getRecommandFriends,
  getZedPay,
  acceptFriend,
  declineFriend,

  setFcmToken,
  getSingleChats,
};
