import http from "k6/http";
import { sleep } from "k6";

// This will export to HTML as filename "result.html" AND also stdout using the text summary
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

// The following config would have k6 ramping up from 1 to 10 VUs for 3 minutes,
// then staying flat at 10 VUs for 5 minutes, then ramping up from 10 to 35 VUs
// over the next 10 minutes before finally ramping down to 0 VUs for another
// 3 minutes.
// export let options = {
//   stages: [
//     { duration: "3m", target: 10 },
//     { duration: "5m", target: 10 },
//     { duration: "10m", target: 35 },
//     { duration: "3m", target: 0 },
//   ],
// };

// https://k6.io/blog/how-to-generate-a-constant-request-rate-with-the-new-scenarios-api/
// https://docs.konghq.com/gateway-oss/2.6.x/sizing-guidelines/
export let options = {
  scenarios: {
    constant_request_rate: {
      executor: "constant-arrival-rate",
      rate: 2500,
      timeUnit: "1s", // 2500 iterations per second, i.e. 2500 RPS
      duration: "3m",
      preAllocatedVUs: 100, // how large the initial pool of VUs would be
      maxVUs: 200, // if the preAllocatedVUs are not enough, we can initialize more
    },
  },
};

export function handleSummary(data) {
  return {
    "result.html": htmlReport(data),
    stdout: textSummary(data, { indent: " ", enableColors: true }),
  };
}

export default function () {
  http.get("http://localhost:8080/search-ip/json/187.110.146.115");
  sleep(1);
}
