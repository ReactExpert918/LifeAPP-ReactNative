import { savePerson, getPerson, getPersonName } from "./persons";
import { saveUserToDatabase, getUserFromDatabase } from "./user";
import { saveGroup, getGroup, getGroupName } from "./groups";

export const DB_INTERNAL = {
  saveUserToDatabase,
  getUserFromDatabase,

  savePerson,
  getPerson,
  getPersonName,

  saveGroup,
  getGroup,
  getGroupName,
};
