import { StyleSheet } from 'react-native';
import { colors } from '../../assets/colors';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.white,
  },
  profileContainer: {
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
  },
  topContainer: {
    backgroundColor: colors.ui.primary,
    width: '100%',
    height: 60,
    flexDirection: 'row',
    padding: 10,
  },
});
