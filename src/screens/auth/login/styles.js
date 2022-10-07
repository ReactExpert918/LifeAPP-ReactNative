import { StyleSheet } from 'react-native';
import { colors } from '../../../assets/colors';
import { textStyles } from '../../../common/text.styles';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
    backgroundColor: colors.bg.primary,
  },
  topContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
    padding: 16,
  },
  logo: {
    width: 140,
    height: 140,
  },
  loginContainer: {
    alignItems: 'flex-start',
    justifyContent: 'center',
    width: '100%',
  },
  loginButton: {
    width: '100%',
    padding: 4,
    marginTop: 16,
  },
  forgotButton: {
    width: '100%',
    padding: 4,
    marginTop: 4,
  },
  bottomContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    paddingBottom: 4,
  },
  registerLabel: {
    ...textStyles.primarySmall,
    textDecorationLine: 'underline',
  },
});
