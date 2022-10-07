import { StyleSheet } from 'react-native';
import { colors } from '../../assets/colors';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  profileContainer: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: colors.bg.lightgray,
    flexDirection: 'row',
    alignItems: 'center',
  },
});
