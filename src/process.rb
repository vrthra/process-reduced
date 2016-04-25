#!/usr/bin/env ruby
require 'set'

def len_tc(lines)
  # vecs will contain 3 records.
  vecs = lines.select {|l| l =~ /INFO: (MinLen|ORIGLEN):/ }.map do |l|
    case l
    when /INFO: ORIGLEN:(.*)/
      $1.to_i
    when /INFO: MinLen:(.*)/
      $1.to_i
    else
      raise l
    end
  end
  return vecs
end

def stmt_cov_tc(lines)
  # vecs will contain 3 records.
  vecs = lines.select {|l| l =~ /INFO: .*VECLINE:/ }.map do |l|
    case l
    when /INFO: RANDOMVECLINE:(.*)/
      $1.split('').map(&:to_i)
    when /INFO: RANDOMTCVECLINE:(.*)/
      $1.split('').map(&:to_i)
    when /INFO: VECLINE:(.*)/
      $1.split('').map(&:to_i)
    else
      raise l
    end
  end
  return vecs
end

def cond_cov_tc(lines)
  # vecs will contain 3 records.
  vecs = lines.select {|l| l =~ /INFO: .*VECCOND:/ }.map do |l|
    case l
    when /INFO: RANDOMVECCOND:(.*)/
      $1.split('').map(&:to_i)
    when /INFO: VECCOND:(.*)/
      $1.split('').map(&:to_i)
    else
      raise l
    end
  end
  return vecs
end

def mut_cov_tc(lines)
  # vecs will contain 3 records.
  v = lines.select {|l| l =~ /INFO: (OrigDetectedMutnats|RANDOMTCMUTS1|MUTS):/ }
  vecs = v.map do |l|
    case l
    when /INFO: OrigDetectedMutnats:\["*(.*)"*\]/
      $1.split(',')
    when /INFO: MUTS:\["*(.*)"*\]/
      $1.split(',')
    when /INFO: RANDOMTCMUTS1:\["*(.*)"*\]/
      $1.split(',')
    else
      raise l
    end
  end
  return vecs
end


def calc_len(covs)
  covs.inject(:+)
end

def calc_cov(covs)
  tcl = covs.transpose.map do |a|
    if a.inject(:+) > 0
      1
    else
      0
    end
  end
  return tcl.inject(:+).to_f * 100.0/ tcl.length
end

def calc_mut(muts)
  Set.new(muts.flatten).length
end

def fix_l(d, k)
  if d.length == 1
    [d[0],d[0],d[0]]
  elsif d.length == 2
    [d[0],d[1],d[1]]
  elsif d.length == 3
    d
  else
    raise "#{k}: #{d.length}"
  end
end


def fix_d(d, k)
  if d.length == 1
    [d[0],d[0],d[0]]
  elsif d.length == 2
    [d[0],d[1],d[0]]
  elsif d.length == 3
    d
  else
    raise "#{k}: #{d.length}"
  end
end

def len_ts(tsuite)
  tcs = tsuite.map {|k,lines| fix_l(len_tc(lines), k) } #.select{|v| v.length != 0}
  return [calc_len(tcs.map{|tc| tc[0]}),calc_len(tcs.map{|tc| tc[1]}),calc_len(tcs.map{|tc| tc[2]})]
end


def stmt_cov_ts(tsuite)
  tcs = tsuite.map {|k,lines| fix_d(stmt_cov_tc(lines), k) } #.select{|v| v.length != 0}
  return [calc_cov(tcs.map{|tc| tc[0]}),calc_cov(tcs.map{|tc| tc[1]}),calc_cov(tcs.map{|tc| tc[2]})]
end

def cond_cov_ts(tsuite)
  tcs = tsuite.map {|k,lines| fix_d(cond_cov_tc(lines), k) } #.select{|v| v.length != 0}
  return [calc_cov(tcs.map{|tc| tc[0]}),calc_cov(tcs.map{|tc| tc[1]}),calc_cov(tcs.map{|tc| tc[2]})]
end

def mut_cov_ts(tsuite)
  tcs = tsuite.map {|k,lines| fix_d(mut_cov_tc(lines), k) } #.select{|v| v.length != 0}
  return [calc_mut(tcs.map{|tc| tc[0]}),calc_mut(tcs.map{|tc| tc[1]}),calc_mut(tcs.map{|tc| tc[2]})]
end


dir = ARGV[0]
tsarr = Dir.glob("#{dir}/*.slog").map {|tc| [tc, File.readlines(tc).map(&:chomp)]}.select{|tcls| tcls[1].length >=20}

tsuite = Hash[tsarr]

puts "Length of test cases for three suites"
p len_ts(tsuite)
puts "Statement coverage for three suites"
p stmt_cov_ts(tsuite)
puts "Condition coverage for three suites"
p cond_cov_ts(tsuite)
puts "Set of killed mutants for three suites"
p mut_cov_ts(tsuite)
