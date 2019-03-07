package verilog_neural_network;


public interface Module {



  public void onInputUpdate(Wire a);

  /**
   * write this thing in verilog form the module itself
   * 
   * @param filepath
   */
  public void toFile(String filepath);

  /**
   * write the signature in a string format how is connected and such including all input and
   * outputs
   */
  public String toVerilog();



}
