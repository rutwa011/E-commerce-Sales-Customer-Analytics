\# Advanced SQL Analysis



\## Objective



Use advanced SQL techniques to answer business questions that require ranking, comparisons across periods, customer segmentation and cumulative calculations.



\## Techniques Demonstrated



| Technique           | Application                                   |

| ------------------- | --------------------------------------------- |

| CTEs                | Break complex analysis into readable steps    |

| `ROW\_NUMBER()`      | Select the first-ranked record within a group |

| `RANK()`            | Rank records while preserving ties            |

| `DENSE\_RANK()`      | Rank records without gaps after ties          |

| `NTILE()`           | Divide customers into spending groups         |

| `LAG()`             | Compare with previous periods or purchases    |

| `LEAD()`            | Compare with subsequent periods               |

| Rolling averages    | Smooth short-term revenue fluctuations        |

| Cumulative sums     | Track revenue accumulated over time           |

| `PERCENTILE\_CONT()` | Calculate spending percentiles                |

| `HAVING`            | Filter groups after aggregation               |



\## Business Applications



\* Compare monthly revenue with previous periods.

\* Identify high-value customers.

\* Rank products within categories.

\* Explore customer purchasing patterns.

\* Analyse product revenue contribution.

\* Identify products with high sales and elevated return activity.

\* Compare product demand across time periods.



\## Interpretation



Advanced SQL makes it possible to answer multi-step questions directly in PostgreSQL. Results should be interpreted in the context of the data's time range, aggregation level and business definitions.



For example, a high-spending customer is not automatically a high-profit customer. Revenue, profit and customer acquisition costs should be considered separately where the data permits.



