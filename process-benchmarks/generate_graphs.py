import pandas as pd
from matplotlib.figure import Figure
from pandas import DataFrame


def read_list_processing_df() -> DataFrame:
    df = pd.read_csv('../benchmark.csv', header=0)
    df = df.drop(['Description'], axis=1)
    df['mean_ns'] = df.mean(axis=1, numeric_only=True)
    df['mean_ms'] = df['mean_ns'] / 1000000

    return df


def get_comparison_df(df: DataFrame):
    list_processing = df.copy().iloc[0:4]
    no_processing = df.copy().iloc[4:6]
    no_processing_ext = no_processing.append(no_processing)

    list_processing['difference_ns'] = list_processing['mean_ns'] - no_processing_ext['mean_ns'].values
    list_processing['difference_ms'] = list_processing['difference_ns'] / 1000000

    return list_processing


def get_pivot_table(df: DataFrame, value_column: str) -> DataFrame:
    return pd.pivot_table(
        df,
        values=value_column,
        index='Processing',
        columns='Mode')


def add_bar_labels(ax):
    for container in ax.containers:
        ax.bar_label(
            container,
            fmt='%.2f',
            padding=5,
            fontsize=12)


def create_formatted_graph(df_to_display: DataFrame):
    ax = df_to_display.plot.bar(color=['#1954A6', '#65656C', '#B0C92B'])
    # KTH CD colors: https://intra.kth.se/en/administration/kommunikation/grafiskprofil

    ax.get_figure().set_size_inches(10, 6)

    add_bar_labels(ax)

    ax.xaxis.grid(False)
    ax.yaxis.grid(True, color='#EEEEEE')
    ax.set_axisbelow(True)

    # ax.set_xticklabels(ax.get_xticks(), rotation=45)
    for tick in ax.get_xticklabels():
        tick.set_rotation(0)

    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(True)

    return ax


def create_absolute_graph(df_to_display: DataFrame, no_of_execs: int) -> Figure:
    ax = create_formatted_graph(df_to_display)
    ax.set_xlabel('List processing form')
    ax.set_ylabel('Average duration over {0} executions [ms]'.format(no_of_execs))
    return ax.get_figure()


def create_comparison_graph(df_to_display: DataFrame, no_of_execs: int) -> Figure:
    ax = create_formatted_graph(df_to_display)
    ax.set_xlabel('List processing form')
    ax.set_ylabel('Average duration over {0} executions compared to no list processing [ms]'.format(no_of_execs))
    return ax.get_figure()


list_processing_df = read_list_processing_df()
comparison_df = get_comparison_df(list_processing_df)

absolute_pivot_table = get_pivot_table(list_processing_df, 'mean_ms')
comparison_pivot_table = get_pivot_table(comparison_df, 'difference_ms')

execution_columns = list(filter(lambda c: c.startswith('T'), list_processing_df.columns))
no_of_executions = len(execution_columns)

create_absolute_graph(absolute_pivot_table, no_of_executions)\
    .savefig('absolute-graph.png', transparent=True)
create_comparison_graph(comparison_pivot_table, no_of_executions) \
    .savefig('comparison-graph.png', transparent=True)
