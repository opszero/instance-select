<%!
  active_ = "rds"
  import json
  import six
%>
<%inherit file="base.mako" />

    <%block name="meta">
      <title>Amazon RDS Instance Comparison</title>
      <meta name="description" content="A free and easy-to-use tool for comparing RDS Instance features and prices."></head>
    </%block>

    <%block name="header">
      <h1 class="banner-ad d-none d-xl-block">EC2Instances.info Easy Amazon <b>RDS</b> Instance Comparison</h1>
    </%block>

    <div class="row mt-3 me-2" id="menu">
      <div class="col-sm-12 ms-2">

        <div class="btn-group-vertical" id='region-dropdown'>
          <label class="dropdown-label mb-1">Region</label>
          <a class="btn dropdown-toggle btn-primary" data-bs-toggle="dropdown" role="button" href="#">
            <i class="icon-globe icon-white"></i>
            <span class="text">US East (N. Virginia)</span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu region-list-dropdown" role="menu">
            <li>
              <input type="text" id="dropdown-search" class="ms-2 mb-2 form-control dropdown-search" placeholder="Search" />
            </li>
            % for region, region_name in regions["main"].items():
            <li>
              <a class="dropdown-item" href="javascript:;" data-region='${region}'>
                <span>${region_name}</span>
                <span class="dropdown-region">${region}</span>
              </a>
            </li>
            % endfor
            <div class="ms-2 mb-2 mt-2">
              <span><strong>Local Zones</strong></span>
            </div>
            % for region, region_name in regions["local_zone"].items():
            <li>
              <a class="dropdown-item" href="javascript:;" data-region='${region}'>
                <span>${region_name}</span>
                <span class="dropdown-region">${region}</span>
              </a>
            </li>
            % endfor
            <div class="ms-2 mb-2 mt-2">
              <span><strong>Wavelength Zones</strong></span>
            </div>
            % for region, region_name in regions["wavelength"].items():
            <li>
              <a class="dropdown-item" href="javascript:;" data-region='${region}'>
                <span>${region_name}</span>
                <span class="dropdown-region">${region}</span>
              </a>
            </li>
            % endfor
          </ul>
        </div>

        <div class="btn-group-vertical d-md-inline-flex d-none" id="pricing-unit-dropdown">
          <label class="dropdown-label mb-1">Pricing Unit</label>
          <a class="btn dropdown-toggle btn-primary" data-bs-toggle="dropdown" role="button" href="#">
            <i class="icon-shopping-cart icon-white"></i>
            <span class="text">Instance</span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <li class="active"><a class="dropdown-item" href="javascript:;" pricing-unit="instance">Instance</a></li>
            <li><a class="dropdown-item" href="javascript:;" pricing-unit="vcpu">vCPU</a></li>
            <li><a class="dropdown-item" href="javascript:;" pricing-unit="memory">Memory</a></li>
          </ul>
        </div>

        <div class="btn-group-vertical" id="cost-dropdown">
          <label class="dropdown-label mb-1">Cost</label>
          <a class="btn dropdown-toggle btn-primary" data-bs-toggle="dropdown" href="#">
            <i class="icon-shopping-cart icon-white"></i>
            <span class="text">Hourly</span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <li><a class="dropdown-item" href="javascript:;" duration="secondly">Per Second</a></li>
            <li><a class="dropdown-item" href="javascript:;" duration="minutely">Per Minute</a></li>
            <li class="active"><a class="dropdown-item" href="javascript:;" duration="hourly">Hourly</a></li>
            <li><a class="dropdown-item" href="javascript:;" duration="daily">Daily</a></li>
            <li><a class="dropdown-item" href="javascript:;" duration="weekly">Weekly</a></li>
            <li><a class="dropdown-item" href="javascript:;" duration="monthly">Monthly</a></li>
            <li><a class="dropdown-item" href="javascript:;" duration="annually">Annually</a></li>
          </ul>
        </div>

        <div class="btn-group-vertical d-none d-md-inline-flex" id='reserved-term-dropdown'>
          <label class="dropdown-label mb-1">Reserved</label>
          <a class="btn dropdown-toggle btn-primary" data-bs-toggle="dropdown" href="#">
            <i class="icon-globe icon-white"></i>
            <span class="text">1 yr - No Upfront</span>
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <li><a class="dropdown-item" href="javascript:;" data-reserved-term='yrTerm1Standard.noUpfront'>1 yr - No Upfront</a></li>
            <li><a class="dropdown-item" href="javascript:;" data-reserved-term='yrTerm1Standard.partialUpfront'>1 yr - Partial Upfront</a></li>
            <li><a class="dropdown-item" href="javascript:;" data-reserved-term='yrTerm1Standard.allUpfront'>1 yr - Full Upfront</a></li>
            <li><a class="dropdown-item" href="javascript:;" data-reserved-term='yrTerm3Standard.partialUpfront'>3 yr - Partial Upfront</a></li>
            <li><a class="dropdown-item" href="javascript:;" data-reserved-term='yrTerm3Standard.allUpfront'>3 yr - Full Upfront</a></li>
          </ul>
        </div>

        <div class="btn-group-vertical" id="filter-dropdown">
          <!-- blank label maintains spacing -->
          <label class="dropdown-label mb-1"><br></label>
          <a class="btn dropdown-toggle btn-primary" data-bs-toggle="dropdown" href="#">
            <i class="icon-filter icon-white"></i>
            Columns
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu" role="menu">
            <!-- table header elements inserted by js -->
          </ul>
        </div>

        <div class="btn-group-vertical">
          <label class="dropdown-label mb-1"><br></label>
          <button class="btn btn-purple btn-compare"
            data-text-on="End Compare"
            data-text-off="Compare">
            Compare
          </button>
        </div>

        <div class="btn-group-vertical">
          <label class="dropdown-label mb-1"><br></label>
          <button class="btn btn-primary btn-clear" id="clear">
            Clear Filters
          </button>
        </div>

        <div class="btn-group-vertical float-end m2 p2" id="search">
          <label class="dropdown-label mb-1"><br></label>
          <input id="fullsearch" type="text" class="form-control d-none d-xl-block" placeholder="Search...">
        </div>

        <div class="btn-group-vertical float-end px-2">
          <label class="dropdown-label mb-1"><br></label>
          <div class="btn-primary" id="export"></div>
        </div>

      </div>
    </div>

  <div class="table-responsive overflow-auto wrap-table flex-fill">
    <table cellspacing="0" style="border-bottom: 0 !important; margin-bottom: 0 !important;" id="data" width="100%" class="table">
      <thead>
        <tr>
          <th class="name all" data-priority="1"><div class="d-none d-md-block">Name</div></th>
          <th class="apiname all" data-priority="1">API Name</th>
          <th class="memory">Memory</th>
          <th class="storage">Storage</th>
          <th class="ebs-throughput">EBS Throughput</th>
          <th class="physical_processor">Processor</th>
          <th class="vcpus">
            <abbr title="Each virtual CPU is a hyperthread of an Intel Xeon core for M3, C4, C3, R3, HS1, G2, I2, and D2">vCPUs</abbr>
          </th>
          <th class="networkperf">Network Performance</th>
          <th class="architecture">Arch</th>

          % for platform, code in {'PostgreSQL': '14'}.items():
            <th class="cost-ondemand cost-ondemand-${code} all" data-priority="1">${platform}</th>
            <th class="cost-reserved cost-reserved-${code}">
              <abbr title='Reserved costs are an "effective" hourly rate, calculated by hourly rate + (upfront cost / hours in reserved term).  Actual hourly rates may vary.'>${platform} Reserved Cost</abbr>
            </th>
          % endfor

          % for platform, code in {'MySQL': '2',  'SQL Server Express': '10','SQL Server Web': '11','SQL Server Standard': '12','SQL Server Enterprise': '15', 'Aurora Postgres & MySQL': '21', 'Aurora I/O Optimized': '211', 'MariaDB': '18', 'Oracle Enterprise': '5'}.items():
            <th class="cost-ondemand cost-ondemand-${code}">${platform} On Demand Cost</th>
            % if code != '211':
            <th class="cost-reserved cost-reserved-${code}">
              <abbr title='Reserved costs are an "effective" hourly rate, calculated by hourly rate + (upfront cost / hours in reserved term).  Actual hourly rates may vary.'>${platform} Reserved Cost</abbr>
            </th>
            % endif
          % endfor

          <th class="ebs-baseline-bandwidth">EBS Optimized: Baseline Bandwidth</th>
          <th class="ebs-baseline-throughput">EBS Optimized: Baseline Throughput (128K)</th>
          <th class="ebs-baseline-iops">EBS Optimized: Baseline IOPS (16K)</th>
          <th class="ebs-max-bandwidth">EBS Optimized: Max Bandwidth</th>
          <th class="ebs-throughput">EBS Optimized: Max Throughput (128K)</th>
          <th class="ebs-iops">EBS Optimized: Max IOPS (16K)</th>
        </tr>
      </thead>
      <tbody>
        % for inst in instances:
        <tr class='instance' id="${inst['instance_type']}">
          <td class="name all"><div class="d-none d-md-block">${inst['pretty_name']}</div></td>
          <td class="apiname"><a href="/aws/rds/${inst['instance_type']}">${inst['instance_type']}</a></td>
          <td class="memory"><span sort="${inst['memory']}">${inst['memory']} GiB</span></td>
          <td class="storage">
            <% storage = inst['storage'] %>
            % if storage == 'EBS Only':
            <span sort="1">0 GiB (EBS only)</span>
            % elif 'Aurora' in inst['storage']:
            <span sort="0">Aurora I/O Optimized</span>
            % else:
            <% products = [int(s) for s in storage.split() if s.isdigit()] %>
            <span sort="${products[0]*products[1]}">${inst['storage']}</span>
            % endif
          </td>
          <td class="ebs-throughput">
            % if 'dedicatedEbsThroughput' not in inst:
            <span sort="0">N/A</span>
            % else:
            <span sort="${inst['dedicatedEbsThroughput']}">
              ${inst['dedicatedEbsThroughput']}
            </span>
            % endif
          <td class="physical_processor">${inst['physicalProcessor'] if 'physicalProcessor' in inst else '-'}</td>
          <td class="vcpus">
            <span sort="${inst['vcpu']}">
              ${inst['vcpu']} vCPUs
            </span>
          </td>
          <td class="networkperf">
            <span sort="${inst['network_sort']}">
              ${inst['network_performance']}
            </span>
          </td>
          <td class="architecture">
            % if inst['arch'] and 'i386' in inst['arch']:
            32/64-bit
            % else:
            64-bit
            % endif
          </td>

          % for platform, code in {'PostgreSQL': '14'}.items():
          <td class="cost-ondemand cost-ondemand-${code}" data-platform='${code}' data-vcpu='${inst['vcpu']}' data-memory='${inst['memory']}'>
            % if inst['pricing'].get('us-east-1', {}).get(code, {}).get('ondemand', 'N/A') != "N/A":
              <span sort="${inst['pricing']['us-east-1'][code]['ondemand']}">
                $${"{:.4f}".format(float(inst['pricing']['us-east-1'][code]['ondemand']))} hourly
              </span>
            % else:
              <span sort="999999">unavailable</span>
            % endif
          </td>
          <td class="cost-reserved cost-reserved-${code}t" data-platform='${code}' data-vcpu='${inst['vcpu']}' data-memory='${inst['memory']}'>
            % if inst['pricing'].get('us-east-1', {}).get(code, {}).get('reserved', 'N/A') != "N/A" and inst['pricing']['us-east-1'][code]['reserved'].get('yrTerm1Standard.noUpfront', 'N/A') != "N/A":
              <span sort="${inst['pricing']['us-east-1'][code]['reserved'].get('yrTerm1Standard.noUpfront')}">
                $${"{:.4f}".format(float(inst['pricing']['us-east-1'][code]['reserved'].get('yrTerm1Standard.noUpfront')))} hourly
              </span>
            % else:
              <span sort="999999">unavailable</span>
            % endif
          </td>
          % endfor

          % for platform, code in {'MySQL': '2', 'SQL Server Express': '10', 'SQL Server Web': '11', 'SQL Server Standard': '12','SQL Server Enterprise': '15', 'Aurora Postgres & MySQL': '21', 'Aurora I/O Optimized': '211', 'MariaDB': '18', 'Oracle Enterprise': '5'}.items():
          <td class="cost-ondemand cost-ondemand-${code}" data-platform='${code}' data-vcpu='${inst['vcpu']}' data-memory='${inst['memory']}'>
            % if inst['pricing'].get('us-east-1', {}).get(code, {}).get('ondemand', 'N/A') != "N/A":
              <span sort="${inst['pricing']['us-east-1'][code]['ondemand']}">
                $${"{:.4f}".format(float(inst['pricing']['us-east-1'][code]['ondemand']))} hourly
              </span>
            % else:
              <span sort="999999">unavailable</span>
            % endif
          </td>
          % if code != '211':
          <td class="cost-reserved cost-reserved-${code}" data-platform='${code}' data-vcpu='${inst['vcpu']}' data-memory='${inst['memory']}'>
            % if inst['pricing'].get('us-east-1', {}).get(code, {}).get('reserved', 'N/A') != "N/A" and inst['pricing']['us-east-1'][code]['reserved'].get('yrTerm1Standard.noUpfront', 'N/A') != "N/A":
              <span sort="${inst['pricing']['us-east-1'][code]['reserved'].get('yrTerm1Standard.noUpfront')}">
                $${"{:.4f}".format(float(inst['pricing']['us-east-1'][code]['reserved'].get('yrTerm1Standard.noUpfront')))} hourly
              </span>
            % else:
              <span sort="999999">unavailable</span>
            % endif
          </td>
          % endif
          % endfor

          <td class="ebs-baseline-bandwidth">
            % if not inst['ebs_baseline_bandwidth']:
            <span sort="0">N/A</span>
            % else:
            <span sort="${inst['ebs_baseline_bandwidth']}">
              ${inst['ebs_baseline_bandwidth']} Mbps  <!-- Not MB/s! -->
            </span>
            % endif
          </td>
          <td class="ebs-baseline-throughput">
            <span sort="${inst['ebs_baseline_throughput']}">
              ${inst['ebs_baseline_throughput']} MB/s
            </span>
          </td>
          <td class="ebs-baseline-iops">
            <span sort="${inst['ebs_baseline_iops']}">
              ${inst['ebs_baseline_iops']} IOPS
            </span>
          </td>
          <td class="ebs-max-bandwidth">
            % if not inst['ebs_max_bandwidth']:
            <span sort="0">N/A</span>
            % else:
            <span sort="${inst['ebs_max_bandwidth']}">
              ${inst['ebs_max_bandwidth']} Mbps  <!-- Not MB/s! -->
            </span>
            % endif
          </td>
          <td class="ebs-throughput">
            <span sort="${inst['ebs_throughput']}">
              ${inst['ebs_throughput']} MB/s
            </span>
          </td>
          <td class="ebs-iops">
            <span sort="${inst['ebs_iops']}">
              ${inst['ebs_iops']} IOPS
            </span>
          </td>
        </tr>
        % endfor
      </tbody>
    </table>
  </div>
