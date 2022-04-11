import { savePersons, getPerson, getPersonName, addPerson } from "./persons";
import { saveUserToDatabase, getUserFromDatabase } from "./user";
import { saveGroups, getGroup, getGroupName } from "./groups";
import { saveMembers, getMember } from "./members";
import { saveFriends, getFriend } from "./friends";
import { saveSingles, getSingle, addSingle } from "./singles";

export const DB_INTERNAL = {
  saveUserToDatabase,
  getUserFromDatabase,

  savePersons,
  getPerson,
  getPersonName,
  addPerson,

  saveGroups,
  getGroup,
  getGroupName,

  saveMembers,
  getMember,

  saveFriends,
  getFriend,

  saveSingles,
  getSingle,
  addSingle,
};
