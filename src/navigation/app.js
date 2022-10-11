import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { APP_NAVIGATION } from '../constants/app';
import { FriendScreen } from '../screens/friend';
import { FriendSearchScreen } from '../screens/friend/search';
import { FriendQRcodeScreen } from '../screens/friend/qrcode';
import { SettingScreen } from '../screens/setting/index';
import { AccountSetting } from '../screens/setting/accountSetting';
import { ChatScreen } from '../screens/chat';
import { ChatDetailsScreen } from '../screens/chat/chatDetails';
import { HomeScreen } from '../screens/home';

const Stack = createStackNavigator();

export const AppNavigator = () => {
  return (
    <>
      <Stack.Navigator
        screenOptions={{ headerShown: false, gestureEnabled: false }}
      >
        {/* <Stack.Screen name={APP_NAVIGATION.home} component={HomeNavigator} /> */}
        {/* <Stack.Screen 
          name="main" 
          component={HomeScreen} 
        />
        <Stack.Screen 
          name={APP_NAVIGATION.chat} 
          component={ChatScreen} 
        /> */}
        <Stack.Screen 
          name={APP_NAVIGATION.friend_add} 
          component={FriendScreen} 
        />
        
        <Stack.Screen
          name={APP_NAVIGATION.friend_search}
          component={FriendSearchScreen}
        />
        <Stack.Screen
          name={APP_NAVIGATION.friend_qrcode}
          component={FriendQRcodeScreen}
        />
        <Stack.Screen
          name={APP_NAVIGATION.setting}
          component={SettingScreen}
        />
        <Stack.Screen
          name={APP_NAVIGATION.account_setting}
          component={AccountSetting}
        />
      </Stack.Navigator>
    </>
  );
};
