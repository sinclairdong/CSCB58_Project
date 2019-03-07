package verilog_neural_network;

import java.util.List;

public class Neuron implements Module {

  private int inputNum;

  private Wire[] input;
  private Wire[] input_BP;
  private Wire output;
  private Wire output_bp;
  private String name;
  private String type;
  private int[] regs;



  public Neuron(int inputNum, String name, String type) {
    this.inputNum = inputNum;
    this.name = name;
    this.type = type;
    this.input = new Wire[inputNum];
    this.input_BP = new Wire[inputNum];
    this.regs = new int[inputNum];
  }

  @Override
  public void onInputUpdate(Wire a) {
    // TODO Auto-generated method stub

  }

  @Override
  public void toFile(String filepath) {
    // TODO Auto-generated method stub

  }

  @Override
  public String toVerilog() {
    // TODO Auto-generated method stub
    return null;
  }

  public int getInputNum() {
    return inputNum;
  }

  public void setInputNum(int inputNum) {
    this.inputNum = inputNum;
  }

  public Wire[] getInput() {
    return input;
  }

  public void setInput(Wire[] input) {
    this.input = input;
  }

  public Wire[] getInput_BP() {
    return input_BP;
  }

  public void setInput_BP(Wire[] input_BP) {
    this.input_BP = input_BP;
  }

  public Wire getOutput() {
    return output;
  }

  public void setOutput(Wire output) {
    this.output = output;
  }

  public Wire getOutput_bp() {
    return output_bp;
  }

  public void setOutput_bp(Wire output_bp) {
    this.output_bp = output_bp;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getType() {
    return type;
  }

  public void setType(String type) {
    this.type = type;
  }

  public int[] getRegs() {
    return regs;
  }

  public void setRegs(int[] regs) {
    this.regs = regs;
  }

}
