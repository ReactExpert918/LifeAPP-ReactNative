import AsyncStorage from "@react-native-community/async-storage";
import { KEY_APP_DATA } from "../../constants/database";

export const saveGroup = async (group) => {
  await AsyncStorage.setItem(
    `${KEY_APP_DATA.GROUP}-${group.objectId}`,
    JSON.stringify(group)
  );

  return;
};

export const getGroup = async (group_id) => {
  const group = await AsyncStorage.getItem(`${KEY_APP_DATA.GROUP}-${group_id}`);
  return JSON.parse(group);
};

export const getGroupName = async (group_id) => {
  const group = await AsyncStorage.getItem(`${KEY_APP_DATA.GROUP}-${group_id}`);
  return JSON.parse(group).name;
};
