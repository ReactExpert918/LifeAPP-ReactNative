import { Dimensions } from 'react-native';

export const SHEETS = {
  imagePicker: 'ImagePicker',
};

export const AGORA_APP_ID = 'b4a232ac6c1e4becb4e4f3440bb93d34';

export const APP_NAVIGATION = {
  home: 'Home',
  setting: 'Settings',
  chat: 'ChatDetail',
  chat_detail: 'ChatDetails',
  video: 'VideoCall',
  audio: 'VoiceCall',
  friend_add: 'FriendAdd',
  friend_qrcode: 'FriendQRCode',
  friend_search: 'FriendSearch',
  group: 'Group',
  group_member: 'GroupMember',
  account_setting: 'AccountSetting',
};

export const PERSONCELLTYPE = {
  group: 'group',
  friend: 'friend',
  chats: 'chats',
  group_header: 'header',
  user: 'user',
};

export const SCREEN_WIDTH = Dimensions.get('window').width;
export const SCREEN_HEIGHT = Dimensions.get('window').height;
