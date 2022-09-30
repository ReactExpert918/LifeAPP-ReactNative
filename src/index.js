import React from 'react';
import { Provider } from 'react-redux';
import { store } from './redux';
import Navigator from './navigation';
import { store, persistor } from './redux';

const App = () => {
  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <Navigator />
      </PersistGate>
    </Provider>
  );
};

export default App;
