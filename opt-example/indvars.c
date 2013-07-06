extern int global_variable = 1;

int indvars(){
  int j = 0;
  for(int i = 7; i*i < 1000; ++i){
     j += global_variable;
  }
  return j;
}
