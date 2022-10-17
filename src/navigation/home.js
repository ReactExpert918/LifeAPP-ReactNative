/* eslint-disable react/prop-types */
/* eslint-disable react/display-name */
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Ionicons from 'react-native-vector-icons/Ionicons';

import { colors } from '../assets/colors';
import { HomeScreen } from '../screens/home';
import { ChatScreen } from '../screens/chat';
import { HomeContextProvider } from '../context/home';

const Tab = createBottomTabNavigator();

const TAB_ICONS = {
  Home: 'md-home',
  Chats: 'md-chatbubbles',
};

const tabBarIcon =
  (iconName) =>
    ({ size, color }) =>
      <Ionicons name={iconName} size={size} color={color} />;

const screenOptions = ({ route }) => {
  const iconName = TAB_ICONS[route.name];

  return {
    tabBarIcon: tabBarIcon(iconName),
    tabBarInactiveTintColor: colors.ui.gray,
    tabBarActiveTintColor: colors.ui.primary,
    headerShown: false,
  };
};

export const HomeNavigator = () => {
  return (
    <HomeContextProvider>
      <Tab.Navigator screenOptions={screenOptions}>
        <Tab.Screen name="Home" component={HomeScreen} />
        <Tab.Screen name="Chats" component={ChatScreen} />
      </Tab.Navigator>
    </HomeContextProvider>
  );
};
