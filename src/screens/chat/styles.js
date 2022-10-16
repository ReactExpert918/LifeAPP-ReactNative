import { StyleSheet } from 'react-native';
import { colors } from '../../assets/colors';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.white,
    paddingTop: 10,
  },
  content: {
    alignItems: 'center',
    justifyContent: 'flex-end',
    flexDirection: 'row',
    borderRadius: 12,
  },
});
