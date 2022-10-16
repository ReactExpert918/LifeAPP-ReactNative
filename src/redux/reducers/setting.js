import { SETTING_STATE } from '../../constants/redux';
 
const initialState = {
  payload: {
    show: false,
    data: '',
  }
};

const Reducer = (state = initialState, action) => {
  switch (action.type) {
  case SETTING_STATE.SETTING_UPDATE:
  {
    return {...state, payload: action.payload};
  }    
          
  default: {
    return state;
  }
  }
};

export default Reducer;