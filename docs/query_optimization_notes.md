\# Views and Query Optimisation



\## Objective



Create reusable analytical views and evaluate how indexes and PostgreSQL execution plans affect query performance.



\## Reusable Views



The project includes or plans the following views:



\* `vw\_monthly\_sales`

\* `vw\_customer\_summary`

\* `vw\_product\_performance`

\* `vw\_operations\_performance`

\* `vw\_channel\_performance`

\* `vw\_business\_kpi\_summary`



These views package frequently used calculations into reusable database objects.



\## Indexes



Indexes were considered for common lookup and join columns, including:



\* `orders.customer\_id`

\* `orders.order\_date`

\* `order\_items.order\_id`

\* `order\_items.product\_id`

\* `orders.return\_status`

\* `orders.warehouse` and `orders.order\_date`



Indexes can improve some queries but consume storage and add overhead to inserts and updates. Their effectiveness depends on data distribution and query patterns.



\## Execution Plan Evaluation



`EXPLAIN ANALYZE` can be used to inspect the actual execution plan and execution time of a query.



A useful comparison records:



\* The query being tested

\* Whether an index is available

\* The execution plan

\* Execution time before and after a change

\* Any relevant changes in database conditions



\## Results and Limitations



Actual performance improvements should only be reported after comparing observed execution plans under reasonably consistent conditions.



A sequential scan is not necessarily inefficient, and a low index-scan count in a small portfolio database does not by itself prove that an index is unnecessary.



Document measured results rather than assuming that creating an index always improves performance.



