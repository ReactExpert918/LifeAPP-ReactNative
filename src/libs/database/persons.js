import AsyncStorage from "@react-native-community/async-storage";
import { KEY_APP_DATA } from "../../constants/database";

export const savePerson = async (person) => {
  await AsyncStorage.setItem(
    `${KEY_APP_DATA.PERSON}-${person.objectId}`,
    JSON.stringify(person)
  );
};

export const getPerson = async (person_id) => {
  const person = await AsyncStorage.getItem(
    `${KEY_APP_DATA.PERSON}-${person_id}`
  );
  return JSON.parse(person);
};

export const getPersonName = async (person_id) => {
  const person = await AsyncStorage.getItem(
    `${KEY_APP_DATA.PERSON}-${person_id}`
  );
  return JSON.parse(person).user_name;
};
