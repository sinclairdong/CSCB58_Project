package verilog_neural_network;

import java.util.List;

public class Wire {
  private Module input;
  private List<Module> output;
  private String id;
  private int bandwidth;
  private int value;

  public String toVerilog() {
    return "wire" + " [" + bandwidth + ":" + "0] " + id + ";\n";
  }


  public Wire(Module input, List<Module> output, String id, int bandwidth) {
    this.input = input;
    this.output = output;
    this.id = id;
    this.bandwidth = bandwidth;
  }

  // if input value changes notify everything in the output
  public void onInputUpdate(int value) {
    this.value = value;
    for (Module m : output) {
      m.onInputUpdate(this);
    }
  }

  public void addOutput(Module output) {
    this.output.add(output);
  }

  public void removeOutput(Module output) {
    this.output.remove(output);
  }

  public Module getInput() {
    return input;
  }

  public void setInput(Module input) {
    this.input = input;
  }

  public int getValue() {
    return value;
  }

  public void setValue(int value) {
    this.value = value;
  }

  public String toString() {
    return this.id;
  }


}
