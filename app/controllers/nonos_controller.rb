class NonosController < ApplicationController
def show
  time = Time.now
  ref = "#{time.strftime("%Y-%m-%d-%H-%M-%S")}-#{time.usec}"
  @message = <<-EOT
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<GUKORT_UB version="1.0">
  <datetime>#{time.strftime("%Y-%m-%d %H:%M:%S")}</datetime>
  <serverMessages>
    <name>Is Alive Test</name>
    <text>The service is alive.</text>
    <originalType>NONE</originalType>
    <reference>#{ref}</reference>
  </serverMessages>
</GUKORT_UB>
    EOT
    render xml: @message
  end
end
